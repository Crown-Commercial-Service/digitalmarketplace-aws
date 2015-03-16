from ..stacks import StackPlan
from ..cli import cli_command


@cli_command('delete')
def delete_cmd(ctx):
    """Destroy AWS environment and terminate running instances."""

    plan = StackPlan.from_ctx(ctx)
    plan.delete()
