import mock

from .helpers import set_cloudformation_stack

from dmaws.stacks import Stack
from dmaws.cloudformation import Cloudformation

AWS_REGION = 'eu-west-1'


class TestCloudformation(object):
    def test_init(self, cloudformation_conn):
        assert Cloudformation(AWS_REGION).conn == cloudformation_conn

    def test_describe_stack(self):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        assert {
            'status': 'CREATE_COMPLETE',
            'outputs': {},
            'events': [],
            'resources': {}
        } == cf.describe_stack(stack)

    def test_create_updates_existing_stack(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws', 'UPDATE_COMPLETE')

        assert not cf.create_stack(stack)['failed']

        cloudformation_conn.create_stack.assert_called_with(
            'aws', template_body=u'{}\n', parameters=[],
            capabilities=['CAPABILITY_IAM']
        )

        cloudformation_conn.update_stack.assert_called_with(
            'aws', template_body=u'{}\n', parameters=[],
            capabilities=['CAPABILITY_IAM']
        )

    def test_create_missing_stack(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        cloudformation_conn.create_stack.side_effect = None
        assert not cf.create_stack(stack)['failed']

        cloudformation_conn.create_stack.assert_called_with(
            'aws', template_body=u'{}\n', parameters=[],
            capabilities=['CAPABILITY_IAM']
        )

        assert not cloudformation_conn.update_stack.called

    def test_delete_stack(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws', 'DELETE_COMPLETE')

        assert not cf.delete_stack(stack)['failed']

        cloudformation_conn.delete_stack.assert_called_with('aws')

    def test_delete_missing_stack(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('missing', 'aws.json').build('st', 'env', {})

        assert not cf.delete_stack(stack)['failed']

    def test_update_stack(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws', 'UPDATE_COMPLETE')

        assert not cf.update_stack(stack)['failed']

        cloudformation_conn.update_stack.assert_called_with(
            'aws', template_body=u'{}\n', parameters=[],
            capabilities=['CAPABILITY_IAM']
        )

    def test_update_missing_stack(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('new', 'tests/templates/aws.json').build('st', 'env', {})

        assert cf.update_stack(stack)['failed']

    def test_wait_for(self):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        assert not cf.wait_for(stack, 'CREATE')['failed']

    def test_wait_for_update(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws',
                                 'UPDATE_COMPLETE')

        assert not cf.wait_for(stack, 'UPDATE')['failed']

    def test_wait_for_rollback(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws',
                                 'ROLLBACK_COMPLETE')

        assert cf.wait_for(stack, 'CREATE')['failed']

    def test_wait_for_failed(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws',
                                 'CREATE_FAILED')

        assert cf.wait_for(stack, 'CREATE')['failed']

    def test_wait_for_status_change(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws', [
            'CREATE_IN_PROGRESS', 'CREATE_COMPLETE'
        ])

        assert not cf.wait_for(stack, 'CREATE', delay=0)['failed']

    def test_wait_for_status_change_failed(self, cloudformation_conn):
        cf = Cloudformation(AWS_REGION)
        stack = Stack('aws', 'tests/templates/aws.json').build('st', 'env', {})

        set_cloudformation_stack(cloudformation_conn, 'aws', [
            'CREATE_IN_PROGRESS', 'ROLLBACK_COMPLETE'
        ])

        assert cf.wait_for(stack, 'CREATE', delay=0)['failed']

    def test_response(self):
        cf = Cloudformation(AWS_REGION)

        assert cf._response({'info': 1}) == {'info': 1, 'failed': False}

    def test_response_failed(self):
        cf = Cloudformation(AWS_REGION)

        assert cf._response({'info': 1}, True) == {'info': 1, 'failed': True}
