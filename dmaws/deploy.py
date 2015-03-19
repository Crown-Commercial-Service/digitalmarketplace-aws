import os

from . import build

import boto.beanstalk
import boto.s3
import boto.exception


class Deploy(object):
    def __init__(self, eb_application, eb_environment, repo_path, region, logger=None, profile_name=None):
        self.log = logger
        self.profile_name = profile_name
        self.beanstalk = BeanstalkClient(region, logger, profile_name)
        self.s3 = S3Client(region, logger, profile_name)

        self.repo_path = repo_path
        self.eb_application = eb_application
        self.eb_environment = eb_environment

    def create_version(self, version_label, with_sha=False, description=''):
        ref, sha, package_path = build.create_archive(self.repo_path)
        self.log('Created a git archive at %s', package_path)

        if with_sha:
            version_label = '{}-{}-{}'.format(version_label, ref, sha[:7])
        package_name = '{}/{}.zip'.format(self.eb_application, version_label)

        bucket = self.beanstalk.get_storage_location()

        self.log('Uploading %s to %s/%s', package_path, bucket, package_name)
        _, s3_key = self.s3.upload_package(bucket, package_name, package_path)

        self.log('Creating a new %s version: %s', self.eb_application, version_label)
        created_version = self.beanstalk.create_application_version(
            self.eb_application,
            version_label,
            bucket,
            s3_key,
            description
        )

        self.log("Removing package file %s", package_path)
        os.remove(package_path)

        return version_label, bool(created_version)

    def deploy(self, version_label, stage):
        self.log("Deploying version %s to %s (%s)",
                 version_label, self.eb_environment, stage)
        self.beanstalk.update_environment(self.eb_environment, version_label)
        build.push_tag(self.repo_path, 'deployed-to-{}'.format(stage))


class S3Client(object):
    def __init__(self, region, logger=None, profile_name=None):
        self.conn = boto.s3.connect_to_region(region,
                                              profile_name=profile_name)
        self.log = logger

    def upload_package(self, bucket_name, package_name, package_file):
        bucket = self.conn.get_bucket(bucket_name)
        if bucket.get_key(package_name):
            self.log('Not replacing existing S3 key %s', package_name)
            return bucket, package_name
        key = bucket.new_key(package_name)
        key.set_contents_from_filename(package_file)

        return bucket, key.key


class BeanstalkClient(object):
    def __init__(self, region, logger=None, profile_name=None):
        self.conn = boto.beanstalk.connect_to_region(region,
                                                     profile_name=profile_name)
        self.log = logger

    def get_storage_location(self):
        response = self.conn.create_storage_location()['CreateStorageLocationResponse']
        return response['CreateStorageLocationResult']['S3Bucket']

    def update_environment(self, environment_name, version_label):
        self.conn.update_environment(
            environment_name=environment_name,
            version_label=version_label
        )

    def create_application_version(self, application_name, version_label,
                                   s3_bucket, s3_key, description):
        try:
            self.conn.create_application_version(
                application_name,
                version_label,
                s3_bucket=s3_bucket,
                s3_key=s3_key,
                description=description
            )
        except boto.exception.BotoServerError as e:
            self.log(e.message)
            return

        return version_label
