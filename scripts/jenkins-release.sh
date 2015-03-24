#!/usr/bin/env bash

[ -d venv ] || virtualenv venv

. ./venv/bin/activate
pip install -e .

if [ "$STAGE" = "Select one" -o "$STAGE" = "" ]; then
  >&2 echo "You must select an environment."
  exit 1
fi

if [ "$APPLICATION_NAME" = "Select one" -o "$STAGE" = "" ]; then
  >&2 echo "You must select an application name."
  exit 1
fi

if [ "$STAGE" = "staging" ]; then
  OPTIONS="--from-profile=preview --release-name=$RELEASE_NAME"
fi

AWS_PROFILE="$STAGE" dmaws $STAGE $STAGE release $APPLICATION_NAME $OPTIONS
