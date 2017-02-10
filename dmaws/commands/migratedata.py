import os

import click

from ..cli import cli_command, STAGES
from ..stacks import StackPlan
from ..rds import RDS, RDSPostgresClient
from ..utils import mkdir_p


EXPORT_SNAPSHOT_NAME = "exportdata"
EXPORT_INSTANCE_NAME = "exportdata"
IMPORT_SECURITY_GROUP_NAME = "importdata-sg"


@cli_command('migratedata', max_apps=0)
@click.argument('target_stage', nargs=1, type=click.Choice(STAGES))
@click.argument('target_environment', nargs=1)
@click.argument('target_vars_file', nargs=1)
@click.argument('exportdata_path', nargs=1, type=click.Path(writable=True), required=False)
def migratedata_cmd(ctx, target_stage, target_environment, target_vars_file, exportdata_path):
    if target_stage not in ['development', 'preview', 'staging']:
        raise Exception("Invalid target stage [{}]".format(target_stage))

    target_ctx = ctx.new_context(
        stage=target_stage,
        environment=target_environment,
        vars_files=[target_vars_file])

    rds, pg_client = create_scrubbed_instance(ctx, target_stage)
    dump_to_target(target_ctx, pg_client, exportdata_path=exportdata_path)

    pg_client.close()

    rds.delete_security_group(rds.get_security_group(IMPORT_SECURITY_GROUP_NAME))
    rds.delete_instance(EXPORT_INSTANCE_NAME)
    rds.delete_snapshot(EXPORT_SNAPSHOT_NAME)


def create_scrubbed_instance(ctx, target_stage):
    rds = RDS(ctx.variables['aws_region'], logger=ctx.log, profile_name=ctx.stage)
    plan = StackPlan.from_ctx(ctx, apps=['database'], profile_name=ctx.stage)
    plan.info()

    snapshot = rds.create_new_snapshot(
        EXPORT_SNAPSHOT_NAME,
        rds.get_instance(plan.get_value('stacks.database.outputs')['URL']).id)

    instance = rds.restore_instance_from_snapshot(
        EXPORT_SNAPSHOT_NAME, EXPORT_INSTANCE_NAME,
        dev_user_ips=ctx.variables['dev_user_ips'],
        vpc_id=ctx.variables['vpc_id'])

    pg_client = RDSPostgresClient.from_boto(
        instance,
        ctx.variables['database']['name'],
        ctx.variables['database']['user'],
        ctx.variables['database']['password'],
        logger=ctx.log
    )

    pg_client.clean_database()

    return rds, pg_client


def dump_to_target(target_ctx, src_pg_client, exportdata_path=None):
    rds = RDS(target_ctx.variables['aws_region'], logger=target_ctx.log, profile_name=target_ctx.stage)
    plan = StackPlan.from_ctx(target_ctx, apps=['database'], profile_name=target_ctx.stage)
    plan.info()

    instance = rds.get_instance(plan.get_value('stacks.database.outputs')['URL'])

    StackPlan.from_ctx(target_ctx, apps=['database_dev_access'], profile_name=target_ctx.stage).create()

    target_pg_client = RDSPostgresClient.from_boto(
        instance,
        target_ctx.variables['database']['name'],
        target_ctx.variables['database']['user'],
        target_ctx.variables['database']['password'],
        logger=target_ctx.log)

    if exportdata_path:
        mkdir_p(os.path.dirname(exportdata_path))
        src_pg_client.dump(exportdata_path)
        target_pg_client.load(exportdata_path)
    else:
        src_pg_client.dump_to(target_pg_client)

    target_pg_client.close()

    StackPlan.from_ctx(target_ctx, apps=['database_dev_access'], profile_name=target_ctx.stage).delete()
