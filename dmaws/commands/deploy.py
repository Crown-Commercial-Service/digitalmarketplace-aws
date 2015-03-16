import click

from ..cli import cli_command
from ..stacks import StackPlan
from ..build import get_application_name
from ..deploy import Deploy


@click.argument('repository_path', nargs=1, type=click.Path(exists=True))
@cli_command('deploy', max_apps=0)
def deploy_cmd(ctx, repository_path):
    """Deploy a new application version to the Elastic Beanstalk environment."""

    app = get_application_name(repository_path)
    ctx.add_apps(app)
    stack_info = StackPlan.from_ctx(ctx).info()[ctx.apps[0]]

    deploy = Deploy(
        stack_info.parameters['ApplicationName'],
        stack_info.parameters['EnvironmentName'],
        repository_path,
        region=ctx.variables['aws_region'],
        logger=ctx.log
    )

    version, created = deploy.create_version(app, with_sha=True)
    deploy.deploy(version, ctx.stage)
