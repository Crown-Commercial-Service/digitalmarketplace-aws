# Terraform modules for Digital Marketplace

## Root modules

 * **aws-dm**: digitalmarketplace AWS account
 * **aws-dm-dev**: digitalmarketplace-development AWS account
 * **aws-dm-prod**: digitalmarketplace-production AWS account

## Requirements

### Install Terraform

Make sure you have at least v0.8 installed: https://www.terraform.io/downloads.html

Download the zip file, extract it and copy the terraform executable to `/usr/local/bin` (or your preferred location).

Check the install with running ```terraform -v```.

### AWS cli

Please follow the instructions here: http://docs.aws.amazon.com/cli/latest/userguide/installing.html

### jq

Please follow the instructions here: https://stedolan.github.io/jq/download/

### Install aws-auth

Follow the instructions outlined here: https://github.com/alphagov/aws-auth

### Direnv (optional)

Install direnv (https://github.com/direnv/direnv) to automatically load environment variables from `.envrc` files

## Initialise

### Set up AWS credentials for different environments

Terraform can be used only with MFA therefore you have to set up your profiles both in `~/.aws/credentials` and `~/.aws/config`

Note: You can use direnv (https://github.com/direnv/direnv) to load the AWS_PROFILE value automatically for the root modules (`aws-dm*/.envrc`). Nonetheless the Terraform wrapper script and the Makefile is going to source the `.envrc` files automatically.

### Example

File: ~/.aws/credentials

```
[dm-main-account]
region=eu-west-1
aws_access_key_id=AKIAI...
aws_secret_access_key=FYd4t...
```

File: ~/.aws/config

```
[profile dm-main-account-infrastructure]
source_profile=dm-andras
mfa_serial=arn:aws:iam::<main account id>:mfa/<your username>
role_arn = arn:aws:iam::<main account id>:role/infrastructure
```

File: root/aws-dm/.envrc

```
export AWS_PROFILE=dm-main-account-infrastructure
```

### Terraform remote state

The remote state files are stored on S3 and the initialisation is automatic when you run the terraform make targets (see below).

### Local secret storage

Follow the set up guide outlined here: https://github.gds/gds/digitalmarketplace-credentials/blob/master/README.md

The Makefile will look for the credentials repository at the directory defined in the DM_CREDENTIALS_REPO environment variable.

## Make targets

You can run the same make targets in any of the root module folders.

```
$ make help
apply-resource                 Run terraform apply with a specific resource target
apply                          Run terraform apply
check-env-vars                 Check mandatory environment variables
plan-resource                  Run terraform plan with a specific resource target
plan                           Run terraform plan
refresh                        Run terraform plan
upload-state                   Upload the local state file to S3, use it carefully
```

For more information check the Makefile contents.

## Run bare Terraform commands

You have to use the terraform wrapper script to run terraform commands directly:

```
cd root/aws-dm
./../../terraform-wrapper output
```

This command would have the same effect:

```
cd root/aws-dm
. .envrc && aws-auth terraform output
```

## Requirements in a new AWS environment

### Create an S3 bucket for storing the Terraform state files

The bucket name should be: `digitalmarketplace-terraform-state-<account>`, where <account> is `main/development/production`. Make sure you turn on versioning.

### IAM groups / AWS users

The first time you should simply use an admin user, and after the first run there will be a Terraform group where you can create additional users.
