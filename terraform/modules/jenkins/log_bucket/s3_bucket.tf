resource "aws_s3_bucket" "jenkins_logs_bucket" {
  bucket        = "${var.name}"
  force_destroy = true
  versioning {
    enabled = true
  }

  # The id 156460612806 is the ELB account (eu-west-1)
  # see https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "*",
            "Resource": "arn:aws:s3:::${var.name}/*",
            "Condition": {
            "Bool": {
                "aws:SecureTransport": "false"
            }
            }
        },
        {
            "Sid": "AWSElasticLoadBalancerWrite",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::156460612806:root"
                ]
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
