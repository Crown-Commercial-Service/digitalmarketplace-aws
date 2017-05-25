#!/usr/bin/env bash

LATEST_IMAGE_IDS=$(docker images -a | awk '$2 == "latest" {print $3}')
ALL_IMAGE_IDS=$(docker images -aq | sort | uniq)

for image_id in $ALL_IMAGE_IDS; do
  if ! echo $LATEST_IMAGE_IDS | grep -q -w $image_id; then
    docker rmi $image_id 2>/dev/null
  fi
done
