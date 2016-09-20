import sys
import json
from datetime import datetime

import click

from ..cli import cli_command, main
from ..stacks import StackPlan
from ..build import get_application_name
from ..github import publish_deployment


@click.argument('repository_path', nargs=1, type=click.Path(exists=True))
@cli_command('deploy', max_apps=0)
def deploy_cmd(ctx, repository_path):
    """Deploy a new application version to the Elastic Beanstalk environment.
    """

    app = get_application_name(repository_path)
    ctx.add_apps(app)
    deploy = StackPlan.from_ctx(ctx).get_deploy(repository_path)

    version, created = deploy.create_version(app, with_sha=True)
    url = deploy.deploy(version)

    if not url:
        sys.exit(1)

    ctx.log("URL: http://%s/", url)


@click.argument('deployments_json', nargs=1, type=click.File())
@click.option('--github-token', help="Github API token", default=None)
@main.command('publish-deployments')
def publish_releases(deployments_json, github_token):
    """Publishes Jenkins deployments JSON dump to Github Deployments API"""

    releases = json.load(deployments_json)
    return all(
        publish_deployment(
            token=github_token,
            repo=release['repo'],
            ref=release['release'],
            environment=release['stage'],
            build=release['build'],
            created_at=datetime.utcfromtimestamp(release['timestamp'] / 1000.0),
            ci_url=release['build_url'],
            status=release['status'],
            logger=click.echo
        )
        for release in releases
    )
