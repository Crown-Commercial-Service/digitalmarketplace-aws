#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = '''
---
module: iam_role
short_description: Maintain AWS IAM roles and instance profiles.
description:
    - Maintains AWS IAM roles, policies and instance profiles.
options:
  name:
    description:
      - Name to use for the IAM Role and Instance Profile
    required: true
  region:
    description:
      - The AWS region to use
    required: true
    default: null
    aliases: []
  state:
    description:
      - Create or delete an IAM role
    required: false
    default: 'present'
    choices: [ "present", "absent" ]
    aliases: []
  policies:
    description:
      - List of policies to attach to the role.
    required: false
notes:
  - Running the task will create an IAM Role and an Instance Profile with
    the given name.
  - If a role already exist all of its policies will be replaced with the
    ones listed in the task.

'''

EXAMPLES = '''
- name: Create IAM role
  iam_role:
    name: elasticsearch-test-cluster-role
    region: eu-west-1
    state: present
    policies:
      - name: ec2discovery
        allow_actions:
          - ec2:DescribeInstances
      - name: iamRead
        allow_actions:
          - iam:List*
          - iam:Get*
'''
import sys
import time
import json
import hashlib

try:
    from boto.iam import connect_to_region
    from boto.exception import BotoServerError
except ImportError:
    print "failed=True msg='boto required for this module'"
    sys.exit(1)


class Role(object):
    def __init__(self, conn, name):
        self.conn = conn
        self.name = name

    def create(self, policies):
        status = self.role_exists(), self.instance_profile_exists()
        role, instance_profile = status

        if not role:
            self.create_role()

        if not instance_profile:
            self.create_instance_profile()

        changed_policies = self.set_role_policies(policies)

        return (not all(status)) or changed_policies

    def remove(self):
        status = self.role_exists(), self.instance_profile_exists()
        role, instance_profile = status

        if instance_profile:
            self.delete_instance_profile()

        if role:
            self.set_role_policies({})
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

    def set_role_policies(self, policies):
        existing_policies = set(self.role_policies())
        wanted_policies = set(policies.keys())

        for policy in (existing_policies - wanted_policies):
            self.remove_role_policy(policy)

        for policy in (wanted_policies - existing_policies):
            self.create_role_policy(policy, policies[policy])

        return existing_policies != wanted_policies

    def role_policies(self):
        response = self.conn.list_role_policies(
            self.name
        )['list_role_policies_response']

        return response['list_role_policies_result']['policy_names']

    def create_role_policy(self, policy_name, policy_text):
        self.conn.put_role_policy(self.name, policy_name, policy_text)

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


def create_policies(role_name, policies):
    full_policies = {}
    for policy in policies:
        policy_text = json.dumps({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": policy['allow_actions'],
                    "Effect": "Allow",
                    "Resource": "*"
                }
            ]
        })
        policy_name = u'{}-{}-policy-{}'.format(
            role_name,
            policy['name'],
            hashlib.sha256(policy_text).hexdigest()
        )

        full_policies[policy_name] = policy_text

    return full_policies


def list_instance_profiles(conn):
    result = conn.list_instance_profiles()['list_instance_profiles_response']
    return [
        profile['instance_profile_name'] for profile in
        result['list_instance_profiles_result']['instance_profiles']
    ]


def main():
    argument_spec = {
        'name': {'required': True},
        'policies': {},
        'region': {'required': True},
        'state': {'default': 'present', 'choices': ['present', 'absent']}
    }

    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True,
    )

    name = module.params['name']
    region = module.params['region']
    policies = module.params['policies'] or []
    state = module.params['state']

    conn = connect_to_region(region)
    role = Role(conn, name)

    full_policies = create_policies(name, policies)

    if state == 'present':
        changed = role.create(full_policies)
        # Wait for instance profile to show up in API response
        while name not in list_instance_profiles(conn):
            time.sleep(0.2)
    elif state == 'absent':
        changed = role.remove()

    module.exit_json(
        changed=changed,
        role=name,
        state=state,
    )

from ansible.module_utils.basic import *
main()
