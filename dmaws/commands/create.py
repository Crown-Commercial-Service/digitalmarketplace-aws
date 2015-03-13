from ..stacks import StackPlan
from ..cli import cli_command


@cli_command('create')
def create_cmd(ctx):
    """Create AWS environment and launch instances"""

    plan = StackPlan.from_ctx(ctx)
    plan.create()
