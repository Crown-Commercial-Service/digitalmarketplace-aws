import os
import sys
import json
import tempfile
import zipfile

import boto3
import boto.s3

from ..cli import cli_command
from ..stacks import StackPlan
from ..utils import param_to_env


@cli_command('lambda-release', max_apps=1)
def lambda_release_cmd(ctx, release_name=None, from_profile=None):
    """Release new AWS Lambda function versions."""

    app = ctx.apps[0]
    plan = StackPlan.from_ctx(ctx, apps=[app])
    plan.info(with_aws=True)

    parameters = dict(plan.get_value('stacks.%s.parameters' % app))
    environment_variables = {
        param_to_env(key): p for key, p in parameters.items() if key.startswith('EnvVar')
    }

    ctx.log('==> Creating an archive for %s', app)
    archive_path = create_zip_archive(ctx.home, app, environment_variables)
    ctx.log('==> Uploading %s to %s/%s', archive_path, parameters['S3Bucket'], parameters['S3Key'])
    upload_archive(ctx.variables['aws_region'], parameters['S3Bucket'], parameters['S3Key'], archive_path)
    os.remove(archive_path)

    ctx.log('==> Updating %s function', parameters['FunctionName'])
    status = update_lambda_function(
        ctx.variables['aws_region'],
        parameters['FunctionName'],
        parameters['S3Bucket'],
        parameters['S3Key']
    )

    if not status:
        sys.exit(1)


def create_zip_archive(cwd, app, env):
    lambda_path = os.path.join(cwd, 'lambdas', app.replace('_lambda', ''))

    package_file, archive_path = tempfile.mkstemp()
    os.close(package_file)

    with zipfile.ZipFile(archive_path, 'a') as archive:
        for root, dirs, files in os.walk(lambda_path):
            for f in dirs + files:
                file_path = os.path.join(root, f)
                archive.write(os.path.join(root, f), arcname=os.path.relpath(file_path, lambda_path))

        # Write stack environment variables to 'env' archive file,
        # so it can be used by the lambda function
        env_file = zipfile.ZipInfo('env')
        env_file.external_attr = 0644 << 16L  # give full read access to env file
        archive.writestr(env_file, json.dumps(env))

    return archive_path


def upload_archive(region, s3_bucket, s3_key, archive_path):
    s3 = boto.s3.connect_to_region(region)
    bucket = s3.get_bucket(s3_bucket)
    key = bucket.new_key(s3_key)
    key.set_contents_from_filename(archive_path)


def update_lambda_function(region, function_name, s3_bucket, s3_key):
    client = boto3.client('lambda', region_name=region)
    response = client.update_function_code(
        FunctionName=function_name,
        S3Bucket=s3_bucket,
        S3Key=s3_key,
    )

    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        return False

    return True
