#!/usr/bin/env python

import os
import sys
import json
import requests
from requests.exceptions import HTTPError


def upload_dump_to_s3():
    s3_post_data_url = json.loads(os.environ['S3_POST_URL_DATA'])
    dump_file = '/tmp/dump.sql.gz.gpg'

    url = s3_post_data_url['url']
    fields = s3_post_data_url['fields']
    files = {"file": open(dump_file, 'r')}

    response = requests.post(url, data=fields, files=files)

    try:
        response.raise_for_status()
    except HTTPError as e:
        print("Error uploading {} to {}: {}".format(dump_file, url, e.args[0]))
        sys.exit(1)
    else:
        print('Successfully uploaded {} to {}'.format(dump_file, url))

if __name__ == "__main__":
    upload_dump_to_s3()
