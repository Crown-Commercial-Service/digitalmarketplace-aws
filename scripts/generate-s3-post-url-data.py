#!/usr/bin/env python
"""
This script will create a presigned url and fields for POSTING to an s3 bucket. This allows someone without permissions
on the bucket to upload a file.

This script must be run by an entity with the right permissions on the bucket.

The url will expire after 600 seconds.

Usage:
scripts/generate-s3-post-url-data.py <bucket> <filename>

"""
import json
import boto3
from docopt import docopt


def generate_s3_post_data(bucket, filename):
    s3 = boto3.client('s3')

    fields = {"acl": "bucket-owner-read"}
    conditions = [
        {"acl": "bucket-owner-read"}
    ]

    post = s3.generate_presigned_post(
        Bucket=bucket,
        Key=filename,
        Fields=fields,
        Conditions=conditions,
        ExpiresIn=600
    )

    return json.dumps(post)

if __name__ == "__main__":
    arguments = docopt(__doc__)
    bucket = arguments['<bucket>']
    filename = arguments['<filename>']
    print(generate_s3_post_data(bucket, filename))
