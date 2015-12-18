import os
import tempfile
import time
from datetime import datetime, timedelta

import boto.beanstalk
import boto.s3
import boto.exception

from . import build


class Deploy(object):
    def __init__(self, eb_application, eb_environment, repo_path=None,
                 region=None, logger=None, profile_name=None):
        self.log = logger or (lambda *args, **kwargs: None)
        self.profile_name = profile_name
        self.beanstalk = BeanstalkClient(region, logger, profile_name)
        self.s3 = S3Client(region, logger, profile_name)

        self.repo_path = repo_path
        self.eb_application = eb_application
        self.eb_environment = eb_environment

    def get_current_version(self):
        env = self.beanstalk.describe_environment(self.eb_environment)
        return env['VersionLabel']

    def create_version(self, version_label, with_sha=False, description='',
                       from_file=None):
        if from_file:
            package_path = from_file
        elif self.repo_path:
            ref, sha, package_path = build.create_archive(self.repo_path)
            self.log('==> Created a git archive at %s', package_path)
        else:
            raise ValueError('Either repo_path or from_file must be set')

        if with_sha:
            version_label = '{}-{}-{}'.format(version_label, ref, sha[:7])

        if not from_file:
            build.add_version_label_to_archive(package_path, version_label)

        package_name = self.get_package_name(version_label)

        bucket = self.get_storage_location()

        self.log('==> Uploading %s to %s/%s',
                 package_path, bucket, package_name)
        _, s3_key = self.s3.upload_package(bucket, package_name, package_path)

        self.log('==> Creating a new %s version: %s',
                 self.eb_application, version_label)
        created_version = self.beanstalk.create_application_version(
            self.eb_application,
            version_label,
            bucket,
            s3_key,
            description
        )

        self.log("==> Removing package file %s", package_path)
        os.remove(package_path)

        return version_label, bool(created_version)

    def prune_old_versions(self, number_to_keep):
        assert isinstance(number_to_keep, (int, float))

        versions = self.beanstalk.list_application_versions(self.eb_application)

        count = 0
        if len(versions) > number_to_keep:
            for version in versions[number_to_keep:]:
                count += 1
                self.beanstalk.delete_application_version(self.eb_application, version['VersionLabel'])

        return count

    def deploy(self, version_label):
        self.log("=== Deploying version %s to %s",
                 version_label, self.eb_environment)
        return self.beanstalk.update_environment(
            self.eb_environment, version_label
        )

    def version_exists(self, version_label):
        return self.beanstalk.application_version_exists(
            self.eb_application,
            version_label)

    def get_package_name(self, version_label):
        return '{}/{}.zip'.format(self.eb_application, version_label)

    def get_storage_location(self):
        return self.beanstalk.get_storage_location()

    def download_package(self, version_label):
        return self.s3.download_package(
            self.get_storage_location(),
            self.get_package_name(version_label),
        )


class S3Client(object):
    def __init__(self, region, logger=None, profile_name=None):
        self.conn = boto.s3.connect_to_region(region,
                                              profile_name=profile_name)
        self.log = logger or (lambda *args, **kwargs: None)

    def upload_package(self, bucket_name, package_name, package_file):
        bucket = self.conn.get_bucket(bucket_name)
        if bucket.get_key(package_name):
            self.log('    Not replacing existing S3 key %s', package_name,
                     color='yellow')
            return bucket, package_name
        key = bucket.new_key(package_name)
        key.set_contents_from_filename(package_file)

        return bucket, key.key

    def download_package(self, bucket_name, package_name):
        bucket = self.conn.get_bucket(bucket_name)
        key = bucket.get_key(package_name)
        if not key:
            raise ValueError('S3 key does not exist {}'.format(package_name))
        package_file, package_path = tempfile.mkstemp()
        os.close(package_file)
        key.get_contents_to_filename(package_path)
        return package_path


class BeanstalkStatusError(ValueError):
    pass


class BeanstalkClient(object):
    def __init__(self, region, logger=None, profile_name=None):
        self.conn = boto.beanstalk.connect_to_region(
            region, profile_name=profile_name
        )
        self.log = logger or (lambda *args, **kwargs: None)

    def get_storage_location(self):
        response = self.conn.create_storage_location()
        response = response['CreateStorageLocationResponse']
        return response['CreateStorageLocationResult']['S3Bucket']

    def update_environment(self, environment_name, version_label):
        result = self.conn.update_environment(
            environment_name=environment_name,
            version_label=version_label
        )['UpdateEnvironmentResponse']['ResponseMetadata']

        request_id = result['RequestId']
        return self.wait_for_ready(environment_name, request_id)

    def wait_for_ready(self, environment_name, request_id, delay=5):
        last_event_time = None
        last_status = None
        success = True

        while True:
            events = self.conn.describe_events(
                request_id=request_id,
                environment_name=environment_name,
                start_time=last_event_time,
            )['DescribeEventsResponse']['DescribeEventsResult']
            events = events['Events']
            if len(events):
                # Not all subsequent messages are associated with the request
                # but they may be relevant.
                request_id = None
                last_event_time = datetime.fromtimestamp(
                    events[0]['EventDate']
                )
                # describe_events returns all events with a start_time greater
                # or equal so we have to add a small buffer
                last_event_time += timedelta(milliseconds=1)
                last_event_time = last_event_time.isoformat()

            if any(event['Severity'] == 'ERROR' for event in events):
                success = False

            for event in reversed(events):
                timestamp = datetime.fromtimestamp(
                    event['EventDate']
                ).isoformat()
                self.log('    %s %s %s',
                         timestamp, event['Severity'], event['Message'])

            info = self.describe_environment(environment_name)
            if info['Status'] != last_status:
                last_status = info['Status']
                self.log('=== %s Environment status is now %s',
                         datetime.utcnow().isoformat(), last_status,
                         color='green' if last_status == 'Ready' else 'yellow')
            if info['Status'] == 'Ready':
                return success and info['CNAME']
            elif info['Status'] != 'Updating':
                raise BeanstalkStatusError(
                    "Unexpected Beanstalk status {}".format(info['Status']))

            time.sleep(delay)

    def describe_environment(self, environment_name):
        response = self.conn.describe_environments(
            environment_names=environment_name
        )['DescribeEnvironmentsResponse']['DescribeEnvironmentsResult']
        return response['Environments'][0]

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
            self.log('    ' + e.message)
            return

        return version_label

    def delete_application_version(self, application_name, version_label):
        self.conn.delete_application_version(
            application_name, version_label,
            delete_source_bundle=False)

    def application_version_exists(self, application_name, version_label):
        return len(self.list_application_versions(application_name, version_label)) > 0

    def list_application_versions(self, application_name, version_label=None):
        if version_label is None:
            response = self.conn.describe_application_versions(application_name)
        else:
            response = self.conn.describe_application_versions(application_name, version_label)

        response = response['DescribeApplicationVersionsResponse']
        result = response['DescribeApplicationVersionsResult']

        return result['ApplicationVersions']
