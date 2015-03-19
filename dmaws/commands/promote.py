import click
import re

from ..cli import cli_command
from ..stacks import StackPlan
from .. import build
from ..deploy import Deploy


@click.argument('repository_path', nargs=1, type=click.Path(exists=True))
@click.option('--release-name')
@click.option('--from-account')
def promote_cmd(ctx, repository_path, release_name=None, from_account=None):
    if ctx.stage == 'staging':
        promote_to_staging(ctx, repository_path, release_name, from_account)
    elif ctx.stage == 'production':
        promote_to_production(ctx, repository_path)
    else:
        raise StandardError("Promotion can only happen to staging or production")


def get_deploy(ctx, repository_path):
    app = build.get_application_name(repository_path)
    ctx.add_apps(app)

    return StackPlan.from_ctx(ctx).get_deploy(repository_path)


def promote_to_staging(ctx, repository_path, release_name, from_account):
    if release_name is None:
        raise StandardError("When promoting to staging a release name must be provided")
    if from_account is None:
        raise StandardError("When promoting to staging the development account must be provided")

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


def promote_to_production(ctx, repository_path):
    deploy = get_deploy(ctx, repository_path)

    release_tag = build.get_release_name_for_tag(repository_path,
                                                 'deployed-to-staging')
    if release_tag is None:
        raise StandardError("Could not find release tag for staging")

    deploy.deploy(release_tag, ctx.stage)
