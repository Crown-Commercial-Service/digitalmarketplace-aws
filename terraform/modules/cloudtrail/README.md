# CloudTrail module

## What is CloudTrail?

CloudTrail is is the name for AWS's user audit log service.

CloudTrail creates log files containing log entries. The log entries correspond to actions by users. If, for example, the root user on an AWS account creates a new EC2 instance then CloudTrail will create a log entry in a log file for this action.

## This module

These modules are used to set up and direct [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) on AWS accounts.

CloudTrail creates log entries for user action events in AWS accounts and puts them in to log files in a specified AWS S3 bucket.
It is also possible (but not required) to export these log files into CloudWatch so they are easier to search and view.

* The `cloudtrail-bucket` module creates a bucket pre-configured with the permissions required for AWS CloudTrail service to put logs in it. If you already know which bucket you want to put the log files in you don't need this.
* The `cloudtrail-cloudwatch` module
  * creates an AWS IAM role for the AWS CloudTrail service to assume
  * creates a AWS CloudWatch log group that the above IAM role can write to
* The `cloudtrail` module creates an AWS CloudTrail trail that writes to the given AWS S3 bucket and (optionally) exports logs to the given AWS CloudWatch log group

## Examples

#### Exporting to someone elses S3 Bucket

GDS policy requires that we set up a CloudTrail 'trail' directed to a bucket owned by RE called `gds-audit-cloudtrails` logging [global service events](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html#cloudtrail-concepts-global-service-events) and any [data events](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-management-and-data-events-with-cloudtrail.html#logging-data-events) considered relevant by the development team setting up the account. We can do this by passing arguments to the `cloudtrail` module which will enable an AWS CloudTrail 'trail' and put the log files it creates into the AWS S3 'bucket' we specify (using the `bucket_name` argument)

```
module "cloudtrail" {
  source              = "../../modules/cloudtrail/cloudtrail"
  trail_name = "digitalmarketplace-gds-audit-cloudtrail" // Can be any name
  bucket_name = "gds-audit-cloudtrails" // This is currently the name of the bucket being used
  s3_bucket_key_prefix = "${var.account_id}" // As per RE guidelines this should be the id of the account exporting the CloudTrail trail log files
}
```


#### Creating our own bucket

CloudTrail is also a convenient way of setting up logging on an AWS account to be viewed by the account users themselves. This can be directed to an S3 bucket and we can also pipe these logs directly to a CloudWatch 'log group'. Here we:
* create an AWS S3 'bucket' that an AWS CloudTrail 'trail' can write to
* create an AWS CloudWatch 'log group' and an AWS IAM 'role'. The AWS CloudTrail service can assume our new AWS IAM 'role' and our AWS IAM 'role' can put things in our AWS CloudWatch 'log group'
* Finally we create an AWS CloudTrail 'trail' that writes to our AWS S3 'bucket' and pipes logs to our AWS CloudWatch 'log group'

In the end we have our AWS CloudTrail log files in our specified S3 bucket and searchable in an AWS CloudWatch 'log group'.

```
// Set up our S3 bucket
module "cloudtrail-bucket" {
  source         = "../../modules/cloudtrail/cloudtrail-bucket"
  s3_bucket_name = "digitalmarketplaces-account-cloudtrail-bucket" // Can be any name
}

// Set up the relevant IAM role and CloudWatch log group
module "cloudtrail-cloudwatch" {
  source            = "../../modules/cloudtrail/cloudtrail-cloudwatch"
  trail_name        = "digitalmarketplaces-account-cloudtrail" // Can be any name
  retention_in_days = 731 // How long to make logs accessible in CloudWatch for
}

// Set up the CloudTrail trail
module "cloudtrail" {
  source                     = "../../modules/cloudtrail/cloudtrail"
  trail_name                 = "digitalmarketplaces-account-cloudtrail" // Can be any name
  s3_bucket_name             = "${module.cloudtrail_bucket.s3_bucket_name}" // This is currently the name of the bucket being used
  s3_bucket_key_prefix       = "${var.account_id}" // As per RE guidelines this should be the id of the account exporting the CloudTrail trail log files
  cloud_watch_logs_role_arn  = "${module.cloudtrail-cloudwatch.cloud_watch_logs_role_arn}"
  cloud_watch_logs_group_arn = "${module.cloudtrail-cloudwatch.cloud_watch_logs_group_arn}"
}
```