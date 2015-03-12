from ..stacks import StackPlan
from ..cli import main, cli_command


@main.command('create')
@cli_command
def create_cmd(ctx):
    """Create AWS environment and launch instances"""

    plan = StackPlan.from_ctx(ctx)
    plan.create()
