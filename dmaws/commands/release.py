import click

from ..cli import cli_command
from ..stacks import StackPlan
from .. import build


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
    deploy = StackPlan.from_ctx(ctx).get_deploy(repository_path)

    release_name = build.get_release_name_for_repo(repository_path)
    if build.tag_exists(repository_path, release_name):
        raise ValueError("Already have a tag for {}".format(release_name))

    build.push_tag(repository_path, release_name)
    version, created = deploy.create_version(release_name)
    deploy.deploy(version, ctx.stage)
