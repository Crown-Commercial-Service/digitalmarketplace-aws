#!/bin/sh

[ "$#" -eq 1 ] || { echo "AWS key name argument required"; exit 1; }

export AWS_KEY_NAME=$1

ansible-playbook playbook.yml -i hosts --private-key=~/.ssh/$AWS_KEY_NAME
