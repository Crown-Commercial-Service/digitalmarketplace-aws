#!/bin/bash

MAIN_ACCOUNT_ID=$(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/terraform/common.json | jq -r '.aws_main_account_id')

for image_type in 'nginx' 'elasticsearch'; do
  printf "Cleaning old $image_type AMIs\n"
  aws-auth aws ec2 describe-images --region=eu-west-1 --owners=$MAIN_ACCOUNT_ID \
    --filters "Name=name,Values=$image_type*" | \
    jq -r '[.Images[]] | sort_by(.CreationDate) | .[0:-1] | map(.ImageId) | join(" ")' | \
    tee /dev/tty | \
    xargs -n1 aws ec2 deregister-image --region=eu-west-1 --image-id
  printf "Old $image_type AMIs cleaned\n\n\n"

  printf "Cleaning old $image_type snapshots\n"
  aws-auth aws ec2 describe-images --region=eu-west-1 --owners=398263320410 \
    --filters "Name=name,Values=$image_type*" | \
    jq -r '[.Images[]] | sort_by(.CreationDate) | .[0:-1] | map(.BlockDeviceMappings[0].Ebs.SnapshotId) | join(" ")' | \
    tee /dev/tty | \
    xargs -n1 aws ec2 delete-snapshot --region=eu-west-1 --snapshot-id
  printf "Old $image_type snapshots cleaned\n\n\n"
done
