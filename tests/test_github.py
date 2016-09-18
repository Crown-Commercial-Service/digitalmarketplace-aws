import pytest
import requests_mock

from datetime import datetime

from dmaws.github import publish_deployment


@pytest.yield_fixture
def rmock():
    with requests_mock.mock() as rmock:
        yield rmock


def test_publish_deployment_without_status(rmock):
    rmock.request(
        "GET", 'https://api.github.com/repos/org/repo/deployments',
        json=[], status_code=200
    )
    rmock.request(
        "POST", 'https://api.github.com/repos/org/repo/deployments',
        json={"id": 1}, status_code=201
    )

    status = publish_deployment(
        token='token',
        repo='org/repo',
        ref='release-1',
        environment='production',
        build=1,
        created_at=datetime.utcnow(),
        ci_url='/1',
    )

    assert status


def test_publish_deployment_with_status(rmock):
    rmock.request(
        "GET", 'https://api.github.com/repos/org/repo/deployments',
        json=[], status_code=200
    )
    rmock.request(
        "POST", 'https://api.github.com/repos/org/repo/deployments',
        json={"id": 1}, status_code=201
    )
    rmock.request(
        "POST", 'https://api.github.com/repos/org/repo/deployments/1/statuses',
        json={"id": 1}, status_code=201
    )

    status = publish_deployment(
        token='token',
        repo='org/repo',
        ref='release-1',
        environment='production',
        build=1,
        created_at=datetime.utcnow(),
        ci_url='/1',
        status='success'
    )

    assert status


def test_dont_publish_if_ref_deployment_already_exists(rmock):
    rmock.request(
        "GET", 'https://api.github.com/repos/org/repo/deployments',
        json=[{'id': 1}], status_code=200
    )

    status = publish_deployment(
        token='token',
        repo='org/repo',
        ref='release-1',
        environment='production',
        build=1,
        created_at=datetime.utcnow(),
        ci_url='/1',
    )

    assert status
