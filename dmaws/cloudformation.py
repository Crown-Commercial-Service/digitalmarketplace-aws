import datetime
import time
from itertools import takewhile

import boto.cloudformation
import boto.exception


class Cloudformation(object):
    def __init__(self, region, logger=None, profile_name=None):
        self.conn = boto.cloudformation.connect_to_region(
            region,
            profile_name=profile_name)
        self.log = logger or (lambda *args, **kwargs: None)

    def create_stack(self, stack):
        try:
            self.conn.create_stack(
                stack.name,
                parameters=stack.parameters.items(),
                template_body=stack.template_body,
                capabilities=['CAPABILITY_IAM'],
            )
        except boto.exception.BotoServerError as e:
            if e.error_code == 'AlreadyExistsException':
                self.log(e.message)
                return self.update_stack(stack)
            else:
                raise e

        return self.wait_for(stack, 'CREATE')

    def update_stack(self, stack):
        info = self.describe_stack(stack)
        if not info:
            self.log('Stack [%s] does not exist', stack.name)
            return self._response(info, failed=True)

        try:
            self.conn.update_stack(
                stack.name,
                parameters=stack.parameters.items(),
                template_body=stack.template_body,
                capabilities=['CAPABILITY_IAM']
            )
        except boto.exception.BotoServerError as e:
            info = self.describe_stack(stack)
            if e.message == 'No updates are to be performed.':
                self.log('Stack [%s] is up-to-date', stack.name)
                return self._response(info)
            else:
                self.log(e.message)
                return self._response(info, failed=True)

        return self.wait_for(stack, 'UPDATE')

    def delete_stack(self, stack):
        info = self.describe_stack(stack)
        if not info:
            self.log('Stack [%s] does not exist', stack.name)
            return self._response(info)

        self.conn.delete_stack(stack.name)
        return self.wait_for(stack, 'DELETE')

    def describe_stack(self, stack):
        try:
            stack = self.conn.describe_stacks(stack.name)[0]
        except boto.exception.BotoServerError as e:
            if 'does not exist' in e.message:
                return {}
            elif 'Rate exceeded' in e.message:
                time.sleep(5)
                return self.describe_stack(stack)
            else:
                self.log(e.message)
                raise e

        return {
            'status': stack.stack_status,
            'outputs': dict(
                (o.key, o.value) for o in stack.outputs
            ),
            'events': [
                (ev.timestamp, str(ev))
                for ev in stack.describe_events()
            ],
            'resources': dict(
                (r.logical_resource_id, r.physical_resource_id)
                for r in stack.describe_resources()
            ),
        }

    def wait_for(self, stack, operation, delay=5):
        last = datetime.datetime.utcnow()
        self.log('Waiting for [%s] to %s', stack.name, operation)
        while True:
            info = self.describe_stack(stack)
            if not info and operation == 'DELETE':
                self.log('Stack [%s] is now deleted', stack.name)
                return self._response(info)
            elif info.get('status') == '%s_COMPLETE' % operation:
                self.log('Stack [%s] is now %s', stack.name, info['status'])
                return self._response(info)
            elif info.get('status') in ['ROLLBACK_COMPLETE',
                                        'ROLLBACK_FAILED',
                                        '%s_ROLLBACK_COMPLETE' % operation,
                                        '%s_FAILED' % operation]:
                return self._response(info, failed=True)
            else:
                new_events = list(
                    takewhile(lambda x: x[0] > last, info.get('events', []))
                )
                for ts, event in reversed(new_events):
                    self.log('%s %s', ts, event)
                    last = ts
                time.sleep(delay)

    def _response(self, stack_info, failed=False):
        stack_info.update({
            'failed': failed,
        })
        return stack_info
