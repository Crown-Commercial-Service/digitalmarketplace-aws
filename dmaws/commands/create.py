import click

from ..stacks import StackPlan
from ..cli import main, cli_command


@main.command('create')
@cli_command
@click.option('--dev-access', '-d', is_flag=True, default=False,
              help="Open service ports for access from user_cidr_ip")
def create_cmd(ctx, dev_access):
    """Create AWS environment and launch instances"""

    plan = StackPlan.from_ctx(ctx)
    plan.create()
