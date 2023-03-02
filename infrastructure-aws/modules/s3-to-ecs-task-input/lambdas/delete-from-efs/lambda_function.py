"""
Delete a file from an EFS filesystem.

"""
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    filename = event["filename"]
    from_folder = event["from_folder"]
    delete_file_path = f"{from_folder}/{filename}"
    logger.info(f"Deleting {delete_file_path}")

    os.remove(delete_file_path)
    logger.info("Completed")
