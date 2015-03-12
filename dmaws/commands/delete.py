from ..stacks import StackPlan
from ..cli import main, cli_command


@main.command('delete')
@cli_command
def delete_cmd(ctx):
    """Destroy AWS environment and terminate running instances."""

    plan = StackPlan.from_ctx(ctx)
    plan.delete()
