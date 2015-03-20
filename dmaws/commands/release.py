import click
import re

from ..cli import cli_command
from ..stacks import StackPlan
from .. import build
from ..deploy import Deploy


@click.argument('repository_path', nargs=1, type=click.Path(exists=True))
@cli_command('release', max_apps=0)
def release_cmd(ctx, repository_path):
    """Create a new application release and deploy.

    This is more detail about the thing
    """
    if ctx.stage != "preview":
        raise StandardError("Creating new releases can only be done against preview")

    app = build.get_application_name(repository_path)
    ctx.add_apps(app)
    stack_info = StackPlan.from_ctx(ctx).info()[ctx.apps[0]]

    deploy = Deploy(
        stack_info.parameters['ApplicationName'],
        stack_info.parameters['EnvironmentName'],
        repository_path,
        region=ctx.variables['aws_region'],
        logger=ctx.log
    )

    release_name = get_release_name(repository_path)
    build.push_tag(repository_path, release_name)
    version, created = deploy.create_version(release_name)
    deploy.deploy(version, ctx.stage)


def get_release_name(repository_path):
    release_name = 'release-{}'.format(get_pull_request_number(
        repository_path))

    if build.tag_exists(repository_path, release_name):
        raise ValueError("Already have a tag for {}".format(release_name))

    return release_name


def get_pull_request_number(repository_path):
    output = build.run_git_cmd(['log', '-1', '--pretty=oneline'],
                               repository_path)
    pattern = re.compile('[a-f0-9]+ Merge pull request #(\d+) from')
    match = pattern.match(output)
    if not match:
        raise ValueError("Last commit was not a merge commit.")
    return match.group(1)
