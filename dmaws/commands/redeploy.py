from ..cli import cli_command
from ..stacks import StackPlan


@cli_command('redeploy', max_apps=1)
def redeploy_cmd(ctx, release_name=None, from_profile=None):
    """Redeploy the currently deployed version

    Should only be used to update the environment after
    configuration change.

    """

    deploy = StackPlan.from_ctx(ctx).get_deploy()
    version_label = deploy.get_current_version()

    return deploy.deploy(version_label)
