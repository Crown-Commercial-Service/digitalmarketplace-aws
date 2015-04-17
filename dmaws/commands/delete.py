import click

from ..stacks import StackPlan
from ..cli import cli_command


@cli_command('delete')
@click.option('--ignore-deps', is_flag=True,
              help='Do not complain if dependent stacks exist')
def delete_cmd(ctx, ignore_deps):
    """Destroy AWS environment and terminate running instances."""

    plan = StackPlan.from_ctx(ctx)
    plan.delete(ignore_deps)
