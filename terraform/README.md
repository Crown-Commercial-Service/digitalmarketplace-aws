# Terraform for the Digital Marketplace

## Projects and modules

The following projects each define and control the state of a section of our infrastructure.

 * **accounts/development**: The digitalmarketplace-development AWS account
 * **accounts/main**: The digitalmarketplace AWS account
 * **accounts/production**: The digitalmarketplace-production AWS account
 * **environments/preview**
 * **environments/staging**
 * **environments/production**

Account projects apply to the AWS account as a whole, so should only contain resources that are created once per
account (eg root Route53 hosted zones, IAM users).

Environment projects apply to individual environments and should contain resources that should be created for each
environment (eg application logs and S3 buckets).

All projects are then able to import and use the functionality they require from our folder of shared modules.

## Requirements

### Install Terraform

Make sure you have Terraform installed: https://www.terraform.io/downloads.html

Note, we suggest installing the latest v0.x.x of Terraform. Terraform is backwards incompatible (i.e. if someone has run
terraform `plan` with version v0.11.3 and then you try to run it with v0.11.2, it will say that you need to update your
tool to atleast v0.11.3) so the minimum version will be based on what the developer before you has used.

Download the zip file, extract it and copy the terraform executable to `/usr/local/bin` (or your preferred location).
Alternatively you can use brew: ```brew install terraform```.

Check the install with running ```terraform -v```.

### AWS cli

Please follow the instructions here: http://docs.aws.amazon.com/cli/latest/userguide/installing.html

### jq

Please follow the instructions here: https://stedolan.github.io/jq/download/

### Install aws-auth

Follow the instructions outlined here: https://github.com/alphagov/aws-auth

### Direnv

Install direnv (https://github.com/direnv/direnv) to automatically load environment variables from `.envrc` files

## Initialise

### Set up AWS credentials for different environments

Terraform can be used only with MFA therefore you have to set up your profiles both in `~/.aws/credentials` and `~/.aws/config`

You will need to set up ```.envrc``` files for each project you wish to use which export the related ```AWS_PROFILE``` value for that project. Direnv (https://github.com/direnv/direnv) will load these automatically when using the Terraform wrapper script and Makefiles.

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
[profile dm-main-account-infrastructure-preview]
source_profile=dm-andras
mfa_serial=arn:aws:iam::<main account id>:mfa/<your username>
role_arn = arn:aws:iam::<main account id>:role/infrastructure
```

File: environments/preview/.envrc

```
export AWS_PROFILE=dm-main-account-infrastructure-preview
```

### Terraform remote state

The remote state files are stored on S3 and the initialisation is automatic when you run the terraform make targets (see below).

### Local secret storage

Follow the set up guide outlined here: https://github.gds/gds/digitalmarketplace-credentials/blob/master/README.md

The Makefile will look for the credentials repository at the directory defined in the DM_CREDENTIALS_REPO environment variable.

You may like to add this to your `~/.bash_profile` or `.envrc` file for easy access.

Example file: ~/.bash_profile

```
export DM_CREDENTIALS_REPO=/absolute/path/to/digital/marketplace/credentials/repo
```

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

Generally you won't need to run bare Terraform commands as our ```Makefile``` should cover most needed scenarios. However, if you do then you should use the terraform wrapper script to run them directly. The terraform wrapper script takes care of loading your ```.envrc``` and running ```aws-auth```.

For example, if you wanted to run ```terraform output``` against preview you can do so:

```
cd environments/preview
../../terraform-wrapper output
```

## Requirements in a clean or completely new AWS environment

### Create an S3 bucket for storing the Terraform state files

The bucket name should be: `digitalmarketplace-terraform-state-<account>`, where <account> is `main/development/production`. Make sure you turn on versioning.

### IAM groups / AWS users

The first time you should simply use an admin user, and after the first run there will be a Terraform group where you can create additional users.
