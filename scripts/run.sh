#!/bin/sh

[ "$#" -eq 2 ] || { echo "AWS key and name arguments required"; exit 1; }

AWS_KEY_NAME=$1
AWS_ENV_NAME=$2
export ANSIBLE_CONFIG=playbooks/ansible.cfg

ansible-playbook playbooks/setup.yml -i playbooks/hosts --private-key=~/.ssh/$AWS_KEY_NAME -e "environment_name=$DEPLOY_ENV keyname=$AWS_KEY_NAME branch_name=$AWS_ENV_NAME"

ansible-playbook playbooks/provision.yml -i playbooks/ec2.py --private-key=~/.ssh/$AWS_KEY_NAME -e "environment_name=$DEPLOY_ENV keyname=$AWS_KEY_NAME branch_name=$AWS_ENV_NAME"
