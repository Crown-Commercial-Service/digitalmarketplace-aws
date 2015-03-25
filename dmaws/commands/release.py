import click

from ..cli import cli_command
from ..stacks import StackPlan
from .. import build


@click.argument('app_name', nargs=1)
@click.option('--release-name')
@click.option('--from-profile')
@cli_command('release', max_apps=0)
def release_cmd(ctx, app_name, release_name=None, from_profile=None):
    """Release an application to preview, staging or production.

    If releasing to preview create a new release tag and push the artefact up.
    If releasing to staging copy the artefact over from the development profile.
    If releasing to production just promote the current staging releasee to production.
    """
    repository_path = build.clone_or_update(ctx.stacks[app_name].repo_url)
    if ctx.stage == "preview":
        release_name = release_to_preview(ctx, repository_path)
    elif ctx.stage == "staging":
        release_to_staging(ctx, repository_path, release_name, from_profile)
    elif ctx.stage == "production":
        release_name = release_to_production(ctx, repository_path)
    else:
        raise ValueError("Invalid stage for release {}".format(ctx.stage))

    previous_release = build.push_deployed_to_tag(repository_path, ctx.stage)
    build.notify_slack(ctx.stage, app_name, release_name, previous_release)


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

    return version


def release_to_staging(ctx, repository_path, release_name, from_profile):
    if release_name is None:
        raise ValueError("Release name required for staging release")
    if from_profile is None:
        raise ValueError("Source profile required for staging release")

    deploy = get_deploy(ctx, repository_path)

    if not deploy.version_exists(release_name):
        source_plan = StackPlan.from_ctx(ctx,
                                         stage='preview',
                                         environment='master',
                                         profile_name=from_profile)
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

    return release_tag
