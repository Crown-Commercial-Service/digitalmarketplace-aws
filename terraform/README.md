# Terraform modules for Digital Marketplace

## Root modules

 * **aws-dm**: digitalmarketplace AWS account
 * **aws-dm-dev**: digitalmarketplace-development AWS account
 * **aws-dm-prod**: digitalmarketplace-production AWS account

## Requirements

### Install Terraform

Make sure you have at least v0.8 installed: https://www.terraform.io/downloads.html

Download the zip file, extract it and copy the terraform executable to /usr/local/bin (or your preferred location).

Check the install with running ```terraform -v```.

### Direnv (optional)

Install direnv (https://github.com/direnv/direnv) to automatically load environment variables from .envrc files

## Initialise

### Set up AWS credentials for different environments

The aws-dm*/.envrc file will be sourced for Terraform therefore you can save your environment-specific AWS
credentials there. These files are in .gitignore so you don't have to worry about committing them accidentally.

#### Example

File: dm-development/.envrc
```
export AWS_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=<access key>
export AWS_SECRET_ACCESS_KEY=<secret key>
```

or if you're using an AWS profile:
```
export AWS_REGION=eu-west-1
export AWS_PROFILE=profile-name
```

Note: defining your credentials in ~/.aws/credentials or ~/.aws/config is more secure and has more options (e.g. you can assume roles or use MFA).

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

## Requirements in a new AWS environment

### Create an S3 bucket for storing the Terraform state files

The bucket name should be: digitalmarketplace-terraform-state-<account>, where <account> is main/development/production. Make sure you turn on versioning.

### IAM groups / AWS users

The first time you should simply use an admin user, and after the first run there will be a Terraform group where you can create additional users.
