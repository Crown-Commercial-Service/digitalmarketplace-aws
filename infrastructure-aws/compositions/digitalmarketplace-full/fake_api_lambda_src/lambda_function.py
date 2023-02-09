"""
API faker to allow frontend service to at least start up.

"""
import json

DUMMY_RESPONSE = {"frameworks": []}


def lambda_handler(event, context):
    return {"statusCode": 200, "body": json.dumps(DUMMY_RESPONSE)}
