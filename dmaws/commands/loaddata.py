import os
import sys

import click
import boto.ec2
import requests

from ..cli import cli_command
from ..stacks import StackPlan
from ..utils import run_cmd

from ..deploy import S3Client

LOADDATA_BUCKET = 'digitalmarketplace-dev-loaddata'


@cli_command('loaddata', max_apps=0)
@click.argument('api_repo_path')
@click.argument('tasks', nargs=-1)
def loaddata_cmd(ctx, api_repo_path, tasks):
    """Load test data for development or preview environment."""

    if not tasks:
        tasks = ['database', 'search']

    plan = StackPlan.from_ctx(ctx, apps=['dev_access'])

    status = plan.create(create_dependencies=False)
    if not status:
        sys.exit(1)

    plan.info(['api'])

    elasticsearch_ip = get_tagged_ec2_instances(
        ctx.variables['aws_region'],
        'elasticsearch-{}-{}'.format(ctx.stage, ctx.environment)
    )[0].ip_address

    db_path = "postgres://{}:{}@{}".format(
        plan.get_value('database.user'),
        plan.get_value('database.password'),
        plan.get_value('stacks.database.outputs.URL')
    )

    s3 = S3Client(ctx.variables['aws_region'], logger=ctx.log)
    dump_file = s3.download_package(LOADDATA_BUCKET,
                                    'digitalmarketplace_dev.dump')

    if 'database' in tasks:
        ctx.log('Inserting data into the database')
        run_cmd([
            'psql', '-d', db_path, '-f', dump_file
        ], ignore_errors=True)

    if 'search' in tasks:
        ctx.log('Creating Elasticsearch index')
        es_endpoint = 'http://{}:9200/services/'.format(elasticsearch_ip)
        requests.put(es_endpoint)

        ctx.log('Inserting data into Elasticsearch')
        run_cmd([
            './scripts/process-g6-into-elastic-search.py',
            es_endpoint,
            plan.get_value('stacks.api.outputs.URL') + '/services',
            plan.get_value('api.auth_tokens')[0]
        ], cwd=api_repo_path, ignore_errors=True)

    os.remove(dump_file)
    plan.delete()


def get_tagged_ec2_instances(region, tag):
    ec2 = boto.ec2.connect_to_region(region)
    reservations = ec2.get_all_instances(filters={
        "tag:Group": tag
    })
    instances = [i for r in reservations for i in r.instances]

    return instances
