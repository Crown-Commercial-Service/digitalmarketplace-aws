"""
Copy an S3 object into an EFS filesystem.

"""
import logging
import uuid

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    from_bucket = event["from_bucket"]
    from_key = event["from_key"]
    to_filename = str(uuid.uuid4())
    to_filepath = f"{event['to_folder']}/{to_filename}"
    logger.info(f"Copying from {from_bucket}/{from_key} to {to_filepath}")

    s3_client = boto3.client("s3")
    body_stream = s3_client.get_object(Bucket=from_bucket, Key=from_key)["Body"]

    bytes_copied = 0
    with open(to_filepath, "wb") as efs_file:
        for chunk in body_stream.iter_chunks():
            bytes_copied += len(chunk)
            efs_file.write(chunk)

    logger.info(f"Copied {bytes_copied:,} byte(s) to {to_filepath}")

    return {"to_filename": to_filename}
