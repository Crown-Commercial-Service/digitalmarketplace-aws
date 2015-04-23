import click

from ..cli import cli_command
from ..stacks import StackPlan


@cli_command('debug-value', max_apps=0)
@click.argument('values', nargs=-1)
@click.option('--with-aws', is_flag=True)
def debug_value_cmd(ctx, values, with_aws):
    """Get values of the given dotted variables."""

    plan = StackPlan.from_ctx(ctx, apps=['all'], logger=None)
    plan.info(with_aws=with_aws)

    for value in values:
        ctx.log("%s: %s", value, plan.get_value(value))


@cli_command('debug-template', max_apps=1)
def debug_template_cmd(ctx):
    """Print the app CloudFormation template after Jinja processing."""
    plan = StackPlan.from_ctx(ctx, logger=None)

    for name, stack in plan.stacks(with_dependencies=False):
        built_stack = plan.build_stack(stack)
        ctx.log(built_stack.template_body)
