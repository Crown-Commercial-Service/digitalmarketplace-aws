#!/usr/bin/env python

import boto3

def generate_s3_post_data():
    s3 = boto3.client('s3')

    fields = {"acl": "private"}
    conditions = [
        {"acl": "private"}
    ]

    post = s3.generate_presigned_post(
        Bucket='digitalmarketplace-database-backups',
        Key='',
        Fields=fields,
        Conditions=conditions
    )

    return post

if __name__ == "__main__":
    print(generate_s3_post_data())
