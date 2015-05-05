import sys

import click

from ..stacks import StackPlan
from ..cli import cli_command


@cli_command('delete')
@click.option('--ignore-dependencies', is_flag=True,
              help='Do not complain if dependent stacks exist')
def delete_cmd(ctx, ignore_dependencies):
    """Destroy AWS environment and terminate running instances."""

    plan = StackPlan.from_ctx(ctx)
    status = plan.delete(ignore_dependencies)
    if not status:
        sys.exit(1)
