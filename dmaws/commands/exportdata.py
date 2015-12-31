import click

from ..cli import cli_command
from ..stacks import StackPlan
from ..rds import RDS, RDSPostgresClient


@cli_command('exportdata', max_apps=0)
def exportdata_cmd(ctx):
    plan = StackPlan.from_ctx(ctx, apps=['database_dev_access'])

    status = plan.create(create_dependencies=False)
    if not status:
        sys.exit(1)

    plan.info(['database'])

    rds = RDS(ctx.variables['aws_region'], logger=ctx.log)
    instance = rds.get_instance(plan.get_value('stacks.database.outputs')['URL'])

    snapshot = rds.create_new_snapshot('exportdata', instance.id)
    tmp_instance = rds.restore_instance_from_snapshot(
        "exportdata", "exportdata",
        vpc_security_groups=instance.vpc_security_groups)

    pg_client = RDSPostgresClient.from_boto(
        tmp_instance,
        plan.get_value('database.name'),
        plan.get_value('database.user'),
        plan.get_value('database.password'),
        logger=ctx.log
    )

    pg_client.clean_database_for_staging()
    pg_client.dump("staging.sql")

    pg_client.clean_database_for_preview()
    pg_client.dump("preview.sql")

    pg_client.close()

    rds.delete_instance('exportdata')
    rds.delete_snapshot('exportdata')
