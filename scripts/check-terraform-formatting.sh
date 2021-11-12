#!/bin/bash
set -ou pipefail

cd terraform

terraform fmt -check -recursive
if [ $? -ne 0 ]; then
  echo "Terraform formatting check has FAILED. Fix formatting issues with \`make terraformat\` from the root of the repository."
  exit 1
fi

echo "Terraform formatting check has PASSED."
