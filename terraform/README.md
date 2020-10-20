# Terraform for the Digital Marketplace

## Projects and modules

The following projects each define and control the state of a section of our infrastructure.

 * **accounts/development**: The digitalmarketplace-development AWS account
 * **accounts/main**: The digitalmarketplace AWS account
 * **accounts/production**: The digitalmarketplace-production AWS account
 * **accounts/backups**: The digitalmarketplace-backups AWS account
 * **environments/preview**
 * **environments/staging**
 * **environments/production**

Account projects apply to the AWS account as a whole, so should only contain resources that are created once per
account (eg root Route53 hosted zones, IAM users).

Environment projects apply to individual environments and should contain resources that should be created for each
environment (eg application logs and S3 buckets).

All projects are then able to import and use the functionality they require from our folder of shared modules.

## Requirements

Unless you're using the Nix environment (https://alphagov.github.io/digitalmarketplace-manual/nix.html) (in which they
are all included), you will need to install the following manually (they are not installed as part of other process
such as `make requirements` or `pip`).

### Install Terraform

Make sure you have Terraform installed. You will need the latest v0.12 version. Terraform is backwards incompatible (i.e. if someone has run terraform `plan` with version v0.12.3 and then you try to run it with v0.12.2, it will say that you need to update your tool to at least v0.12.3) so the minimum version will be based on what the developer before you has used.

You should use [tfenv](https://github.com/tfutils/tfenv) to install and manage Terraform, as this is the easiest way to get the right version. You may instead [download it directly](https://www.terraform.io/downloads.html), or run `brew install terraform`.

Check the install with running `terraform --version`.

### AWS cli

Please follow the instructions here: http://docs.aws.amazon.com/cli/latest/userguide/installing.html

### jq

Please follow the instructions here: https://stedolan.github.io/jq/download/

### Install aws-auth

Follow the instructions outlined here: https://github.com/alphagov/aws-auth

## Initialise

### Set up AWS credentials for different environments

Terraform can be used only with MFA therefore you have to set up your profiles both in `~/.aws/credentials` and `~/.aws/config`

Before running a terraform command you need to set the `AWS_PROFILE` environment variable. This needs to be set to a profile that has permissions to complete the tasks included in the command.

You can find details of the AWS profiles in the [AWS accounts section](https://alphagov.github.io/digitalmarketplace-manual/aws-accounts.html#available-roles) of the Digital Marketplace manual.


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
[profile development-infrastructure]
source_profile=default
mfa_serial=arn:aws:iam::<main account id>:mfa/<IAM username>
role_arn=arn:aws:iam::<digitalmarketplace-development account id>:role/infrastructure
```

Command:

```
AWS_PROFILE=development-infrastructure aws-auth terraform init
# Shortcut commands defined in Makefile-common
AWS_PROFILE=development-infrastructure make plan
AWS_PROFILE=development-infrastructure make apply
```


### Terraform remote state

The remote state files are stored on S3 and the initialisation is automatic when you run the terraform make targets (see below).

### Local secret storage

Follow the set up guide outlined here: https://github.gds/gds/digitalmarketplace-credentials/blob/master/README.md

The Makefile will look for the credentials repository at the directory defined in the DM_CREDENTIALS_REPO environment variable.

You may like to add this to your `~/.bash_profile` for easy access.

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

Generally you won't need to run bare Terraform commands as our ```Makefile``` should cover most scenarios. However, if you do then you should use ```aws-auth``` in conjunction with the ```AWS_PROFILE``` environment to supply AWS with the correct credentials.

For example, if you wanted to run ```terraform output``` against preview you can do so:

```
AWS_PROFILE=development-infrastructure aws-auth terraform output
```

Or, if you're exclusively working on ```preview``` for a while:

```
export AWS_PROFILE=development-infrastructure
aws-auth terraform output
```

That way all your commands will run against preview until you change the environment variable.

## Requirements in a clean or completely new AWS environment

### Create an S3 bucket for storing the Terraform state files

The bucket name should be: `digitalmarketplace-terraform-state-<account>`, where `<account>` is `main/development/production`. Make sure you turn on versioning.

### IAM groups / AWS users

The first time you should simply use an admin user, and after the first run there will be a Terraform group where you can create additional users.
