try:
    import __builtin__ as builtins
except ImportError:
    import builtins
import mock
import pytest
import requests
import requests_mock

from dmaws.hosted_graphite.create_alerts import (
    create_alert, create_alerts, ALERTS,
    get_missing_logs_alert_json, create_missing_logs_alerts
)
from dmaws.hosted_graphite.create_dashboards import generate_dashboards


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

    create_alert('api_key', {'foo': 'bar'})

    assert rmock.last_request.json() == {'foo': 'bar'}


def test_create_alert_raises_for_status_on_error(rmock):
    rmock.request(
        "POST", 'https://api.hostedgraphite.com/v2/alerts/',
        status_code=500,
    )

    with pytest.raises(requests.exceptions.HTTPError) as exc:
        create_alert('api_key', {'foo': 'bar'})

    assert str(exc.value) == '500 Server Error: None for url: https://api.hostedgraphite.com/v2/alerts/'


def test_get_missing_logs_alert_json_has_additional_criteria_for_non_router_apps():
    assert get_missing_logs_alert_json('preview', 'api') == {
        "name": "preview api missing logs",
        "metric": "cloudwatch.incoming_log_events.preview.api.nginx_logs.sum",
        "alert_criteria": {
            "type": "missing",
            "time_period": 15,
        },
        "notification_channels": ["Notify DM 2ndline"],
        "notification_type": ["every", 60],
        "info": """No incoming log events metrics for the last 15 minutes for the api app. This could be either the \
application logs or the nginx logs or both. This could indicate either a problem with metric shipping to Hosted \
Graphite or that the logs are not being created.\nDO NOT MANUALLY EDIT - Set up through Hosted Graphite API so GUI may \
have inconsistencies. See HG alerting API for details""",
        "additional_criteria": {
            "b": {
                "metric": "cloudwatch.incoming_log_events.preview.api.application_logs.sum",
                "type": "missing",
                "time_period": 15,
            }
        },
        "expression": "a || b",

    }


def test_get_missing_logs_alert_json_does_not_have_additional_criteria_for_router_app():
    assert get_missing_logs_alert_json('preview', 'router') == {
        "name": "preview router missing logs",
        "metric": "cloudwatch.incoming_log_events.preview.router.nginx_logs.sum",
        "alert_criteria": {
            "type": "missing",
            "time_period": 15,
        },
        "notification_channels": ["Notify DM 2ndline"],
        "notification_type": ["every", 60],
        "info": """No incoming log events metrics for the last 15 minutes for the router app. This could be either the \
application logs or the nginx logs or both. This could indicate either a problem with metric shipping to Hosted \
Graphite or that the logs are not being created.\nDO NOT MANUALLY EDIT - Set up through Hosted Graphite API so GUI may \
have inconsistencies. See HG alerting API for details"""
    }


@mock.patch('dmaws.hosted_graphite.create_alerts.get_missing_logs_alert_json')
@mock.patch('dmaws.hosted_graphite.create_alerts.create_alert')
def test_create_missing_logs_alerts_creates_alerts_for_each_environment_and_app(create_alert, get_missing_logs_json):
    get_missing_logs_json.return_value = {'foo': 'bar'}
    create_missing_logs_alerts('api_key', ['preview', 'production'], ['api', 'buyer-frontend'])

    assert create_alert.call_args_list == [
        mock.call('api_key', get_missing_logs_json.return_value)
    ] * 4
    assert get_missing_logs_json.call_args_list == [
        mock.call('preview', 'api'),
        mock.call('preview', 'buyer-frontend'),
        mock.call('production', 'api'),
        mock.call('production', 'buyer-frontend'),
    ]


@mock.patch('dmaws.hosted_graphite.create_dashboards.get_grafana_dashboard_folder')
def test_generate_dashboards_calls_hosted_graphite_api(get_grafana_dashboard_folder, rmock):
    get_grafana_dashboard_folder.return_value = '/tmp'
    rmock.request(
        "PUT", "https://api.hostedgraphite.com/api/v2/grafana/dashboards/",
        json={"id": 1}, status_code=201
    )

    with mock.patch.object(builtins, 'open', mock.mock_open(read_data='{"foo": "bar"}')):
        generate_dashboards('api_key')

    assert rmock.last_request.json() == {"foo": "bar"}


@mock.patch('dmaws.hosted_graphite.create_dashboards.get_grafana_dashboard_folder')
def test_generate_dashboards_raises_for_status_on_error(get_grafana_dashboard_folder, rmock):
    get_grafana_dashboard_folder.return_value = '/tmp'
    rmock.request(
        "PUT", 'https://api.hostedgraphite.com/api/v2/grafana/dashboards/',
        status_code=500,
    )

    with pytest.raises(requests.exceptions.HTTPError) as exc:
        with mock.patch.object(builtins, 'open', mock.mock_open(read_data='{"foo": "bar"}')):
            generate_dashboards('api_key')

    assert str(exc.value) == '500 Server Error: None for url: https://api.hostedgraphite.com/api/v2/grafana/dashboards/'
