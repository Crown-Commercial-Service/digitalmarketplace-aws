import click

from ..cli import cli_command
from ..stacks import StackPlan
from .. import build


@click.argument('repository_path', nargs=1, type=click.Path(exists=True))
@click.option('--release-name')
@click.option('--from-account')
@cli_command('release', max_apps=0)
def release_cmd(ctx, repository_path, release_name=None, from_account=None):
    """Create a new application release and deploy.

    This is more detail about the thing
    """
    if ctx.stage == "preview":
        release_to_preview(ctx, repository_path)
    elif ctx.stage == "staging":
        release_to_staging(ctx, repository_path, release_name, from_account)
    elif ctx.stage == "production":
        release_to_production(ctx, repository_path)
    else:
        raise ValueError("Invalid stage for release {}".format(ctx.stage))


def get_deploy(ctx, repository_path):
    app = build.get_application_name(repository_path)
    ctx.add_apps(app)

    return StackPlan.from_ctx(ctx).get_deploy(repository_path)


def release_to_preview(ctx, repository_path):
    deploy = get_deploy(ctx, repository_path)

    release_name = build.get_release_name_for_repo(repository_path)
    if build.tag_exists(repository_path, release_name):
        raise ValueError("Already have a tag for {}".format(release_name))

    build.push_tag(repository_path, release_name)
    version, created = deploy.create_version(release_name)
    deploy.deploy(version, ctx.stage)


def release_to_staging(ctx, repository_path, release_name, from_account):
    if release_name is None:
        raise ValueError("Release name required for staging release")
    if from_account is None:
        raise ValueError("Source account required for staging release")

    deploy = get_deploy(ctx, repository_path)

    if not deploy.version_exists(release_name):
        source_plan = StackPlan.from_ctx(ctx,
                                         stage='preview',
                                         environment='master',
                                         profile_name=from_account)
        source_deploy = source_plan.get_deploy(repository_path)
        package_path = source_deploy.download_package(release_name)

        deploy.create_version(release_name, from_file=package_path)

    deploy.deploy(release_name, ctx.stage)


def release_to_production(ctx, repository_path):
    deploy = get_deploy(ctx, repository_path)

    release_tag = build.get_release_name_for_tag(repository_path,
                                                 'deployed-to-staging')
    if release_tag is None:
        raise StandardError("Could not find release tag for staging")

    deploy.deploy(release_tag, ctx.stage)
