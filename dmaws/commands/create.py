import click

from ..stacks import StackPlan
from ..cli import cli_command


@cli_command('create')
@click.option('--ignore-dependencies', is_flag=True,
              help='Do not update or create dependencies')
def create_cmd(ctx, ignore_dependencies):
    """Create AWS environment and launch instances"""

    plan = StackPlan.from_ctx(ctx)
    plan.create(create_dependencies=not ignore_dependencies)
