from collections import namedtuple

import boto.exception

CFOutput = namedtuple('Output', ['key', 'value'])
CFEvent = namedtuple('Event', ['timestamp'])
CFResource = namedtuple('Resource', [
    'logical_resource_id', 'physical_resource_id'
])


def set_cloudformation_stack(cloudformation_mock, stack_name, status,
                             outputs=None, events=None, resources=None):

    if not hasattr(cloudformation_mock, '_stacks'):
        cloudformation_mock._stacks = {}

    def get_stack(stack):
        if stack in cloudformation_mock._stacks:
            return [cloudformation_mock._stacks[stack]]
        else:
            raise boto.exception.BotoServerError(404, 'No Stack')

    def create_stack(stack, *args, **kwargs):
        if stack in cloudformation_mock._stacks:
            exc = boto.exception.BotoServerError(400, '')
            exc.error_code = 'AlreadyExistsException'
            raise exc

    cloudformation_mock.describe_stacks.side_effect = get_stack
    cloudformation_mock.create_stack.side_effect = create_stack

    def stack_status(self):
        if isinstance(self.status_, list):
            return self.status_.pop(0)
        else:
            return self.status_

    CFStack = namedtuple('Stack', [
        'status_', 'outputs', 'events_', 'resources_'
    ])
    CFStack.describe_events = lambda self: self.events_
    CFStack.describe_resources = lambda self: self.resources_
    CFStack.stack_status = property(stack_status)

    cloudformation_mock._stacks[stack_name] = CFStack(
        status,
        outputs or [],
        events or [],
        resources or [],
    )


def set_boto_response(mock_object, method_name, response=None, metadata=None):
    getattr(mock_object, method_name).return_value = boto_response_dict(
        method_name, response, metadata
    )


def set_boto_responses(mock_object, method_name, responses):
    getattr(mock_object, method_name).side_effect = [
        boto_response_dict(method_name, response, metadata)
        for response, metadata in responses
    ]


def boto_response_dict(method_name, response=None, metadata=None):
    method_key = method_name.title().replace('_', '')
    return {
        '{}Response'.format(method_key): {
            '{}Result'.format(method_key): response,
            'ResponseMetadata': metadata,
        }
    }
