import pytest
import mock
from mock import call

from .helpers import set_boto_response, set_boto_responses

from dmaws.deploy import Deploy
from dmaws.deploy import S3Client
from dmaws.deploy import BeanstalkClient, BeanstalkStatusError

AWS_REGION = 'eu-west-1'


class TestDeploy(object):
    def test_deploy_init(self, s3_conn, beanstalk_conn):
        deploy = Deploy('app', 'env')
        assert deploy.s3.conn == s3_conn
        assert deploy.beanstalk.conn == beanstalk_conn

    def test_deploy(self):
        assert Deploy('app', 'env').deploy('release-1') == 'test.domain.local'

    def test_create_version_with_repo_archive(self, s3_bucket):
        deploy = Deploy('app', 'env', repo_path='test-path')

        assert deploy.create_version('release-1') == ('release-1', True)

        s3_bucket.new_key.assert_called_with('app/release-1.zip')
        key = s3_bucket.new_key.return_value
        key.set_contents_from_filename.assert_called_with('/tmp/tempfile')

    def test_create_version_from_file(self, s3_bucket):
        deploy = Deploy('app', 'env')
        assert deploy.create_version('release-1', from_file='file.zip') == (
            'release-1', True
        )

        s3_bucket.new_key.assert_called_with('app/release-1.zip')
        key = s3_bucket.new_key.return_value
        key.set_contents_from_filename.assert_called_with('file.zip')

    def test_create_version_no_file_or_repo(self):
        deploy = Deploy('app', 'env')

        with pytest.raises(ValueError):
            deploy.create_version('release-1')

    def test_create_version_existing(self, s3_bucket):
        s3_bucket.get_key.return_value = True
        deploy = Deploy('app', 'env', repo_path='test-path')

        assert deploy.create_version('release-1') == ('release-1', True)
        assert not s3_bucket.new_key.called

    def test_create_version_with_sha(self, git_info):
        deploy = Deploy('app', 'env', repo_path='test-path')
        assert deploy.create_version('release', with_sha=True) == (
            'release-master-dd93edd', True
        )

    def test_prune_old_versions(self, beanstalk_conn):
        deploy = Deploy('app', 'env', repo_path='test-path')
        set_boto_response(beanstalk_conn, 'describe_application_versions', {
            'ApplicationVersions': [
                {
                    'ApplicationName': 'app',
                    'VersionLabel': 'release-3',
                },
                {
                    'ApplicationName': 'app',
                    'VersionLabel': 'release-2',
                },
                {
                    'ApplicationName': 'app',
                    'VersionLabel': 'release-1',
                },
            ]
        })
        assert deploy.prune_old_versions(1) == 2
        beanstalk_conn.delete_application_version.assert_has_calls(
            [call('app', 'release-2', delete_source_bundle=False),
             call('app', 'release-1', delete_source_bundle=False)])

    def test_prune_old_versions_nothing_to_prune(self, beanstalk_conn):
        deploy = Deploy('app', 'env', repo_path='test-path')
        set_boto_response(beanstalk_conn, 'describe_application_versions', {
            'ApplicationVersions': [
                {
                    'ApplicationName': 'app',
                    'VersionLabel': 'release-3',
                },
                {
                    'ApplicationName': 'app',
                    'VersionLabel': 'release-2',
                },
                {
                    'ApplicationName': 'app',
                    'VersionLabel': 'release-1',
                },
            ]
        })
        assert deploy.prune_old_versions(4) == 0
        assert not beanstalk_conn.delete_application_version.called

    def test_prune_old_versions_fails_with_bad_number_to_keep(self):
        deploy = Deploy('app', 'env', repo_path='test-path')
        for number_to_keep in ['123', None, deploy]:
            with pytest.raises(AssertionError):
                deploy.prune_old_versions(number_to_keep)

    def test_get_current_version(self):
        assert Deploy('app', 'env').get_current_version() == 'release-0'

    def test_version_exists(self):
        assert Deploy('app', 'env').version_exists('release-0')

    def test_version_doesnt_exist(self, beanstalk_conn):
        set_boto_response(beanstalk_conn, 'describe_application_versions', {
            'ApplicationVersions': []
        })
        assert not Deploy('app', 'env').version_exists('release-0')

    def test_get_package_name(self):
        assert Deploy('app', 'env').get_package_name(
            'release-1'
        ) == 'app/release-1.zip'

    def test_storage_location(self):
        assert Deploy('app', 'env').get_storage_location() == 'test-bucket'

    def test_download_package(self, s3_bucket):
        s3_bucket.get_key.return_value = mock.Mock()
        assert Deploy('app', 'env').download_package(
            'release-0'
        ) == '/tmp/tempfile'


class TestS3Client(object):
    def test_s3_init(self, s3_conn):
        assert S3Client(AWS_REGION).conn is s3_conn

    def test_s3_upload_package(self, s3_conn, s3_bucket):
        s3_client = S3Client(AWS_REGION)
        s3_client.upload_package('test-bucket', 'test-package', '')

        s3_conn.get_bucket.assert_called_with('test-bucket')
        s3_bucket.get_key.assert_called_with('test-package')
        s3_bucket.new_key.assert_called_with('test-package')

    def test_s3_upload_existing_package(self, s3_conn, s3_bucket):
        s3_bucket.get_key.return_value = True
        s3_client = S3Client(AWS_REGION)
        s3_client.upload_package('test-bucket', 'test-package', '')

        s3_conn.get_bucket.assert_called_with('test-bucket')
        s3_bucket.get_key.assert_called_with('test-package')
        assert not s3_bucket.new_key.called

    def test_s3_download_package(self, s3_conn, s3_bucket):
        s3_bucket.get_key.return_value = mock.Mock()
        s3_client = S3Client(AWS_REGION)
        package = s3_client.download_package('test-bucket', 'test-package')

        s3_conn.get_bucket.assert_called_with('test-bucket')
        s3_bucket.get_key.assert_called_with('test-package')

        assert package == '/tmp/tempfile'

    def test_s3_download_missing_package(self, s3_conn, s3_bucket):
        s3_client = S3Client(AWS_REGION)

        with pytest.raises(ValueError):
            s3_client.download_package('test-bucket', 'test-package')


class TestBeanstalkClient(object):
    def test_beanstalk_init(self, beanstalk_conn):
        assert BeanstalkClient(AWS_REGION).conn is beanstalk_conn

    def test_get_storage_location(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.get_storage_location() == 'test-bucket'

    def test_wait_for_ready(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.wait_for_ready('test-env', '1') == 'test.domain.local'

    def test_wait_for_ready_events_logging(self):
        logger = mock.Mock()
        beanstalk = BeanstalkClient(AWS_REGION, logger=logger)
        assert beanstalk.wait_for_ready('test-env', '1') == 'test.domain.local'

        logger.assert_has_calls([
            mock.call(mock.ANY, mock.ANY, 'UPDATE', 'msg'),
            mock.call(mock.ANY, mock.ANY, 'Ready', color=mock.ANY),
        ])

    def test_wait_for_ready_error_event(self, beanstalk_conn):
        logger = mock.Mock()
        beanstalk = BeanstalkClient(AWS_REGION, logger=logger)

        set_boto_response(beanstalk_conn, 'describe_events', {
            'Events': [
                {'EventDate': 1427976389, 'Severity': 'ERROR', 'Message': ''}
            ]
        })

        assert not beanstalk.wait_for_ready('test-env', '1')

        logger.assert_has_calls([
            mock.call(mock.ANY, mock.ANY, 'ERROR', ''),
            mock.call(mock.ANY, mock.ANY, 'Ready', color=mock.ANY),
        ])

    def test_wait_for_ready_unknown_status(self, beanstalk_conn):
        logger = mock.Mock()
        beanstalk = BeanstalkClient(AWS_REGION, logger=logger)

        set_boto_response(beanstalk_conn, 'describe_environments', {
            'Environments': [
                {
                    'Status': 'NotARealStatus',
                    'CNAME': 'test.domain.local'
                }
            ]
        })

        with pytest.raises(BeanstalkStatusError):
            beanstalk.wait_for_ready('test-env', '1')

        logger.assert_has_calls([
            mock.call(mock.ANY, mock.ANY, 'UPDATE', 'msg'),
            mock.call(mock.ANY, mock.ANY, 'NotARealStatus', color=mock.ANY),
        ])

    def test_wait_for_ready_status_change(self, beanstalk_conn):
        logger = mock.Mock()
        beanstalk = BeanstalkClient(AWS_REGION, logger=logger)

        set_boto_responses(beanstalk_conn, 'describe_events', [
            ({'Events': [
                {'EventDate': 1, 'Severity': 'UPDATE', 'Message': '1'},
                {'EventDate': 0, 'Severity': 'UPDATE', 'Message': '0'},
            ]}, None),
            ({'Events': [
                {'EventDate': 2, 'Severity': 'UPDATE', 'Message': '2'},
            ]}, None),
            ({'Events': []}, None),
        ])

        set_boto_responses(beanstalk_conn, 'describe_environments', [
            ({'Environments': [{
                'Status': 'Updating',
                'CNAME': None
            }]}, None),
            ({'Environments': [{
                'Status': 'Updating',
                'CNAME': None
            }]}, None),
            ({'Environments': [{
                'Status': 'Ready',
                'CNAME': 'test.domain.local'
            }]}, None),
        ])

        assert beanstalk.wait_for_ready('test', '1', 0) == 'test.domain.local'

        logger.assert_has_calls([
            mock.call(mock.ANY, mock.ANY, 'UPDATE', '0'),
            mock.call(mock.ANY, mock.ANY, 'UPDATE', '1'),
            mock.call(mock.ANY, mock.ANY, 'Updating', color=mock.ANY),
            mock.call(mock.ANY, mock.ANY, 'UPDATE', '2'),
            mock.call(mock.ANY, mock.ANY, 'Ready', color=mock.ANY),
        ])

    def test_update_environment(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.update_environment('test-env', 'test-version')

    def test_update_environment_returns_cname(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert(beanstalk.update_environment('test-env', 'test-version')
               == 'test.domain.local')

    def test_update_environment_failure(self, beanstalk_conn):
        beanstalk = BeanstalkClient(AWS_REGION)
        set_boto_response(beanstalk_conn, 'describe_events', {
            'Events': [
                {'EventDate': 1427976389, 'Severity': 'ERROR', 'Message': ''}
            ]
        })

        assert not beanstalk.update_environment('test-env', 'test-version')

    def test_describe_environment(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.describe_environment('test') == {
            'Status': 'Ready',
            'CNAME': 'test.domain.local',
            'VersionLabel': 'release-0',
        }

    def test_create_application_version(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.create_application_version(
            'test-app', 'test-version', 'test-bucket', 'test-package', ''
        ) == 'test-version'

    def test_delete_application_version(self, beanstalk_conn):
        beanstalk = BeanstalkClient(AWS_REGION)
        beanstalk.delete_application_version('test-app', 'test-version')
        beanstalk_conn.delete_application_version.assert_called_once_with(
            'test-app', 'test-version', delete_source_bundle=False
        )

    def test_application_version_exists(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.application_version_exists('test-env', 'test-version')

    def test_list_application_versions(self, beanstalk_conn):
        beanstalk = BeanstalkClient(AWS_REGION)
        set_boto_response(beanstalk_conn, 'describe_application_versions', {
            'ApplicationVersions': [
                {
                    'ApplicationName': 'test-env',
                    'VersionLabel': 'release-3',
                },
                {
                    'ApplicationName': 'test-env',
                    'VersionLabel': 'release-2',
                },
                {
                    'ApplicationName': 'test-env',
                    'VersionLabel': 'release-1',
                },
            ]
        })
        assert len(beanstalk.list_application_versions('test-env')) == 3
        beanstalk_conn.describe_application_versions.assert_called_once_with('test-env')

    def test_list_application_versions_with_version_label(self, beanstalk_conn):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert len(beanstalk.list_application_versions('test-env', 'test-version')) == 1
        beanstalk_conn.describe_application_versions.assert_called_once_with('test-env', 'test-version')
