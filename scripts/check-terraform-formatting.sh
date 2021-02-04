#!/bin/bash

LINT_OUTPUT=$(terraform fmt -write=false -list=true -diff=true -recursive terraform)
if [ ! -z "${LINT_OUTPUT}" ]; then
  echo "${LINT_OUTPUT}"
  echo "Terraform formatting check has FAILED. Fix formatting issues with \`terraform fmt -write=true -list=true -diff=true -recursive terraform\` from the root of the repository."
  exit 1
fi

echo "Terraform formatting check has PASSED."
