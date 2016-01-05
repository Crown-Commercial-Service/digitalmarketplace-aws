import os

import click

from ..cli import cli_command
from ..stacks import StackPlan
from ..rds import RDS, RDSPostgresClient


@cli_command('exportdata', max_apps=0)
@click.option('--export-path', default='.',
              help="Path to write export files.")
def exportdata_cmd(ctx, export_path):
    rds = RDS(ctx.variables['aws_region'], logger=ctx.log)

    snapshot = rds.create_new_snapshot(
        'exportdata',
        rds.get_instance(plan.get_value('stacks.database.outputs')['URL']).id)

    tmp_instance = rds.restore_instance_from_snapshot(
        "exportdata", "exportdata",
        dev_user_ips=ctx.variables['dev_user_ips'],
        vpc_id=ctx.variables['vpc_id'])

    pg_client = RDSPostgresClient.from_boto(
        tmp_instance,
        ctx.variables['database']['name'],
        ctx.variables['database']['user'],
        ctx.variables['database']['password'],
        logger=ctx.log
    )

    pg_client.clean_database_for_staging()
    pg_client.dump(os.path.join(export_path, "staging.sql"))

    pg_client.clean_database_for_preview()
    pg_client.dump(os.path.join(export_path, "preview.sql"))

    pg_client.close()

    rds.delete_instance('exportdata')
    rds.delete_snapshot('exportdata')
