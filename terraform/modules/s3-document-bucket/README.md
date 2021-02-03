# S3 Document Bucket module

## What is S3?

AWS S3 (or Amazon Simple Storage Service) is AWS's object based storage solution.

The Digital Marketplace uses this storage service to store documents required for the site such as supplier service documents, contract docuemtns and some presistent downloads.

# This module

This module is used to set up a documnet bucket in line with the Digital Marketplace's existing conventions.

It will also attached a specified bucket policy.


## Examples

#### Simple document bucket

```
module "a_bucket" {
  source              = "../../modules/s3-document-bucket"
  environment         = "preview"                                            # Used as a bucket name suffix in line with current conventions
  bucket_name         = "submissions"                                        # Actual name
  log_bucket_arn      = aws_s3_bucket.server_access_logs_bucket.arn     # A bucket to log access to
  read_object_roles   = ["arn:aws:iam::<SOME-ACCOUNT-ID>:role/<SOME-ROLE>"]  # Roles to give read
  write_object_roles  = []                                                   # Roles to give write
  list_bucket_roles   = ["arn:aws:iam::<SOME-ACCOUNT-ID>:role/<SOME-ROLE>"]  # Roles to give list
}
```
