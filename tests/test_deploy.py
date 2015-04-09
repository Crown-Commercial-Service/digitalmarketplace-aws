import pytest
import mock

from .helpers import set_boto_response, set_boto_responses

from dmaws.deploy import S3Client
from dmaws.deploy import BeanstalkClient, BeanstalkStatusError

AWS_REGION = 'eu-west-1'


class TestS3Client(object):
    def test_s3_init(self, s3_conn):
        assert S3Client(AWS_REGION).conn is s3_conn

    def test_s3_upload_package(self, s3_conn, s3_bucket):
        s3_client = S3Client(AWS_REGION)
        s3_bucket.get_key.return_value = False
        s3_client.upload_package('test-bucket', 'test-package', '')

        s3_conn.get_bucket.assert_called_with('test-bucket')
        s3_bucket.get_key.assert_called_with('test-package')
        s3_bucket.new_key.assert_called_with('test-package')

    def test_s3_upload_existing_package(self, s3_conn, s3_bucket):
        s3_client = S3Client(AWS_REGION)
        s3_client.upload_package('test-bucket', 'test-package', '')

        s3_conn.get_bucket.assert_called_with('test-bucket')
        s3_bucket.get_key.assert_called_with('test-package')
        assert not s3_bucket.new_key.called

    def test_s3_download_package(self, s3_conn, s3_bucket):
        s3_client = S3Client(AWS_REGION)
        package = s3_client.download_package('test-bucket', 'test-package')

        s3_conn.get_bucket.assert_called_with('test-bucket')
        s3_bucket.get_key.assert_called_with('test-package')

        assert package == '/tmp/tempfile'

    def test_s3_download_missing_package(self, s3_conn, s3_bucket):
        s3_client = S3Client(AWS_REGION)
        s3_bucket.get_key.return_value = False

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
            mock.call(mock.ANY, 'Ready'),
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
            mock.call(mock.ANY, 'Ready'),
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
            mock.call(mock.ANY, 'NotARealStatus'),
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
            mock.call(mock.ANY, 'Updating'),
            mock.call(mock.ANY, mock.ANY, 'UPDATE', '2'),
            mock.call(mock.ANY, 'Ready'),
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
            'CNAME': 'test.domain.local'
        }

    def test_create_application_version(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.create_application_version(
            'test-app', 'test-version', 'test-bucket', 'test-package', ''
        ) == 'test-version'

    def test_application_version_exists(self):
        beanstalk = BeanstalkClient(AWS_REGION)
        assert beanstalk.application_version_exists('test-env', 'test-version')
