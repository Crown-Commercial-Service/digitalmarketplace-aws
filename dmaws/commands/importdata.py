import click

from ..cli import cli_command
from ..stacks import StackPlan
from ..rds import RDSPostgresClient


@cli_command('importdata', max_apps=0)
@click.argument('export_file')
def importdata_cmd(ctx, export_file):
    """Import data into an environments database."""
    plan = StackPlan.from_ctx(ctx, apps=['database_dev_access'])

    if not plan.create(create_dependencies=False):
        ctx.log("Failed to allow dev access", color='red')
        sys.exit(1)

    plan.info(['database'])

    pg_client = RDSPostgresClient.from_url(
        plan.get_value('stacks.database.outputs.URL'),
        plan.get_value('database.user'),
        plan.get_value('database.password'),
        logger=ctx.log)

    ctx.log("Loading data into the database")
    pg_client.load(export_file)

    if not plan.delete():
        ctx.log("Failed to remove dev access", color='red')
        sys.exit(1)
