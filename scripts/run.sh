#!/bin/sh

[ "$#" -eq 1 ] || { echo "AWS key name argument required"; exit 1; }

AWS_KEY_NAME=$1
export ANSIBLE_CONFIG=playbooks/ansible.cfg

ansible-playbook playbooks/playbook.yml -i playbooks/hosts --private-key=~/.ssh/$AWS_KEY_NAME -e "environment=$DEPLOY_ENV keyname=$AWS_KEY_NAME"
