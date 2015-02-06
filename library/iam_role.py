#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import json

try:
    from boto.iam import connect_to_region
    from boto.exception import BotoServerError
except ImportError:
    print "failed=True msg='boto required for this module'"
    sys.exit(1)

POLICY = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}


class Role(object):
    def __init__(self, conn, name):
        self.conn = conn
        self.name = name

    def create(self, policy_name, policy):
        status = self.role_exists(), self.instance_profile_exists()
        role, instance_profile = status

        if not role:
            self.create_role()

        if not instance_profile:
            self.create_instance_profile()

        self.set_role_policy(policy_name, policy)

        return not all(status)

    def remove(self, policy_name):
        status = self.role_exists(), self.instance_profile_exists()
        role, instance_profile = status

        if instance_profile:
            self.delete_instance_profile()

        if role:
            self.remove_role_policy(policy_name)
            self.delete_role()

        return any(status)

    def role_exists(self):
        try:
            self.conn.get_role(self.name)
            return True
        except BotoServerError as e:
            if e.status == 404:
                return False
            raise

    def create_role(self):
        self.conn.create_role(self.name)
        return self.name

    def set_role_policy(self, policy_name, policy):
        self.conn.put_role_policy(self.name, policy_name, json.dumps(policy))

    def remove_role_policy(self, policy_name):
        self.conn.delete_role_policy(self.name, policy_name)

    def delete_role(self):
        self.conn.delete_role(self.name)

    def instance_profile_exists(self):
        try:
            self.conn.get_instance_profile(self.name)
            return True
        except BotoServerError as e:
            if e.status == 404:
                return False
            raise

    def create_instance_profile(self):
        self.conn.create_instance_profile(self.name)
        self.conn.add_role_to_instance_profile(self.name, self.name)

    def delete_instance_profile(self):
        self.conn.remove_role_from_instance_profile(self.name, self.name)
        self.conn.delete_instance_profile(self.name)


def main():
    argument_spec = {
        'name': {'required': True},
        'policy_name': {},
        'policy': {},
        'region': {'required': True},
        'state': {'default': 'present', 'choices': ['present', 'absent']}
    }

    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True,
    )

    name = module.params['name']
    region = module.params['region']
    policy = module.params['policy']
    state = module.params['state']

    conn = connect_to_region(region)
    role = Role(conn, name)

    if state == 'present':
        changed = role.create('Allow-EC2-access', policy or POLICY)
    elif state == 'absent':
        changed = role.remove('Allow-EC2-access')

    module.exit_json(
        changed=changed,
        role=name,
        state=state,
    )

from ansible.module_utils.basic import *
main()
