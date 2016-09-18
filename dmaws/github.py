from datetime import datetime

import requests


def create_github_deployment(token, repo, ref, environment, payload=None):
    return requests.post(
        'https://api.github.com/repos/{}/deployments'.format(repo),
        headers={'Authorization': 'token {}'.format(token)} if token else None,
        json={
            'ref': ref,
            'auto_merge': False,
            'required_contexts': [],
            'environment': environment,
            'payload': payload
        }
    )


def set_github_deployment_status(token, repo, deployment_id, state, target_url=None):
    return requests.post(
        'https://api.github.com/repos/{}/deployments/{}/statuses'.format(repo, deployment_id),
        headers={'Authorization': 'token {}'.format(token)} if token else None,
        json={
            'state': state,
            'target_url': target_url,
        }
    )


def get_github_deployments(token, repo, ref=None, environment=None):
    return requests.get(
        'https://api.github.com/repos/{}/deployments'.format(repo),
        headers={'Authorization': 'token {}'.format(token)} if token else None,
        params={'ref': ref, 'environment': environment}
    )


def publish_deployment(token, repo, ref, environment, build, created_at, ci_url, status=None,
                       logger=None):
    log = logger or (lambda *args, **kwargs: None)

    ref_deployments = get_github_deployments(token, repo, ref, environment)
    if ref_deployments.status_code == 200 and ref_deployments.json():
        log('Deployment for {}@{} to {} already exists'.format(repo, ref, environment))
        return True

    created_at = created_at.isoformat()[:-7] + 'Z'
    deployment = create_github_deployment(
        token, repo, ref, environment,
        {
            'ci_build_id': build,
            'created_at': created_at,
        }
    )

    if deployment.status_code // 100 != 2:
        log(u'Failed to create deployment for {}@{}: {}'.format(
            repo, ref,
            deployment.json()
        ))
        return False

    log('Created deployment for {}@{} to {}'.format(repo, ref, environment))

    if status is not None:
        deployment_status = set_github_deployment_status(
            token, repo,
            deployment.json()['id'],
            status,
            ci_url,
        )

        if deployment_status.status_code // 100 != 2:
            log(u'Failed to set deployment status for {} {}: {}'.format(
                repo, deployment.json()['id'],
                deployment_status.json()
            ))
            return False

        log('Set deployment status for {}@{} to {}'.format(repo, ref, status))

    return True
