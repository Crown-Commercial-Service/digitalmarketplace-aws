import mock
import pytest
import requests
import requests_mock

from dmaws.hosted_graphite.create_alerts import create_alert, create_alerts, ALERTS


@pytest.yield_fixture
def rmock():
    with requests_mock.mock() as rmock:
        yield rmock


@mock.patch('dmaws.hosted_graphite.create_alerts.create_alert')
def test_create_alerts_calls_create_alert_for_each_alert(create_alert):
    create_alerts('api_key')
    assert create_alert.call_args_list == [
        mock.call('api_key', alert) for alert in ALERTS
    ]


def test_create_alert_posts_to_hosted_graphite_api(rmock):
    rmock.request(
        "POST", 'https://api.hostedgraphite.com/v2/alerts/',
        json={"id": 1}, status_code=201
    )

    create_alert('api_key', ALERTS[0])

    assert rmock.last_request.json() == {
        "name": "Production Router 500s",
        "metric": "cloudwatch.application_500s.production.router.500s.sum",
        "alert_criteria": {
            "type": "above",
            "above_value": 0
        },
        "notification_channels": ["Notify DM 2ndline"],
        "notification_type": ["every", 60],
        "info": "500s have occured"
    }


def test_create_alert_raises_for_status_on_error(rmock):
    rmock.request(
        "POST", 'https://api.hostedgraphite.com/v2/alerts/',
        status_code=500,
    )

    with pytest.raises(requests.exceptions.HTTPError) as exc:
        create_alert('api_key', ALERTS[0])

    assert str(exc.value) == '500 Server Error: None for url: https://api.hostedgraphite.com/v2/alerts/'


def test_get_missing_logs_alert_json_has_additional_criteria_for_frontend_and_api_apps():
    pass


def test_get_missing_logs_alert_json_does_not_have_additional_criteria_for_router_app():
    pass


def test_create_missing_logs_alerts_creates_alerts():
    pass


def test_generate_dashboards():
    pass
