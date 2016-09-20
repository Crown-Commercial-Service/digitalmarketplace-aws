import sys
import os
from datetime import datetime

import click

from ..cli import cli_command
from ..stacks import StackPlan
from ..github import publish_deployment
from .. import build


@click.option('--release-name')
@click.option('--from-profile')
@click.option('--skip-publishing', is_flag=True, help="Do not publish the deployment on Github")
@cli_command('release', max_apps=1)
def release_cmd(ctx, release_name=None, from_profile=None, skip_publishing=False):
    """Release an application to preview, staging or production.

    If releasing to preview:
        create a new release tag and push the artefact up.

    If releasing to staging:
        copy the artefact over from the development profile.

    If releasing to production:
        just promote the current staging releasee to production.

    """
    repository_path = build.clone_or_update(ctx.stacks[ctx.apps[0]].repo_url)
    if ctx.stage == "preview":
        success, release_name = release_to_preview(ctx, repository_path)
    elif ctx.stage == "staging":
        success, release_name = release_to_staging(ctx, repository_path,
                                                   release_name, from_profile)
    elif ctx.stage == "production":
        success, release_name = release_to_production(ctx, repository_path)
    else:
        raise ValueError("Invalid stage for release {}".format(ctx.stage))

    if not success:
        sys.exit(1)

    ctx.out("RELEASE_NAME", release_name)
    build.push_deployed_to_tag(repository_path, ctx.stage, release_name)

    if skip_publishing:
        return

    success = publish_deployment(
        token=os.getenv('GITHUB_TOKEN'),
        repo=ctx.stacks[ctx.apps[0]].repo_url.partition(':')[-1].replace('.git', ''),
        ref=release_name,
        environment=ctx.stage,
        build=os.getenv('BUILD_NUMBER'),
        created_at=datetime.utcnow(),
        ci_url=os.getenv('BUILD_URL'),
        status='success',
        logger=ctx.log
    )

    if not success:
        sys.exit(1)


def get_deploy(ctx, repository_path):
    app = build.get_application_name(repository_path)
    ctx.add_apps(app)

    return StackPlan.from_ctx(ctx).get_deploy(repository_path)


def release_to_preview(ctx, repository_path):
    deploy = get_deploy(ctx, repository_path)

    release_name = build.get_release_name_for_repo(repository_path)

    if deploy.version_exists(release_name):
        ctx.log('Redeploying existing version %s', release_name)
        return deploy.deploy(release_name), release_name

    if build.tag_exists(repository_path, release_name):
        raise ValueError("Already have a tag for {}".format(release_name))

    deploy.prune_old_versions(os.environ.get('DM_NUM_APPLICATIONS_TO_KEEP', 20))
    version, created = deploy.create_version(release_name)
    build.push_tag(repository_path, release_name)

    return deploy.deploy(version), release_name


def release_to_staging(ctx, repository_path, release_name, from_profile):
    if not release_name:
        release_name = build.get_release_name_for_tag(repository_path, 'deployed-to-preview')
        ctx.log("Deploying current preview version %s", release_name)
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

        deploy.prune_old_versions(os.environ.get('DM_NUM_APPLICATIONS_TO_KEEP', 20))
        deploy.create_version(release_name, from_file=package_path)

    return deploy.deploy(release_name), release_name


def release_to_production(ctx, repository_path):
    deploy = get_deploy(ctx, repository_path)

    release_tag = build.get_release_name_for_tag(repository_path,
                                                 'deployed-to-staging')
    if release_tag is None:
        raise StandardError("Could not find release tag for staging")

    return deploy.deploy(release_tag), release_tag
