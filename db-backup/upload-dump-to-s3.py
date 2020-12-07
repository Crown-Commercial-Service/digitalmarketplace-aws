#!/usr/bin/env python

import os
import json
import subprocess


def upload_dump_to_s3():
    s3_post_url_data = json.loads(os.environ['S3_POST_URL_DATA'])
    dump_file = "/app/{}".format(os.environ['DUMP_FILE_NAME'])
    url = s3_post_url_data['url']
    fields = s3_post_url_data['fields']
    curl_args = ['curl', '--fail']
    for k, v in fields.items():
        curl_args.append('-F')
        curl_args.append(f"{k}={v}")
    curl_args.append('-F')
    curl_args.append(f"file=@{dump_file}")
    curl_args.append(url)
    try:
        response = subprocess.check_output(curl_args)
        print(response)
    except subprocess.CalledProcessError as e:
        raise Exception(f"Upload failed with error: {e.output}")

    print('Successfully uploaded {} to {}'.format(dump_file, url))


if __name__ == "__main__":
    upload_dump_to_s3()
