# -*- coding: utf-8 -*-
import json
import requests


ALERTS = [
    {
        "name": "Production Router 500s",
        "metric": "cloudwatch.application_500s.production.router.500s.sum",
        "alert_criteria": {
            "type": "above",
            "above_value": 0
        },
        "notification_channels": ["Notify DM 2ndline"],  # Hardcoded name, channel had been set up manually already
        "notification_type": ["every", 60],
        "info": "500s have occured"
    },
    {
        "name": "Production Router 429s",
        "metric": "cloudwatch.router_429s.production.router.429s.sum",
        "alert_criteria": {
            "type": "above",
            "above_value": 0
        },
        "notification_channels": ["Notify DM 2ndline"],
        "notification_type": ["every", 60],
        "info": """429s responses being returned from the production router. Check CloudWatch for the IP address to make
sure this is a crawler rather than a legitimate request"""
    },
    {
        "name": "Production Router slow requests (10+ seconds)",
        "metric": "cloudwatch.request_time_buckets.production.router.request_time_bucket_9.sum",
        "alert_criteria": {
            "type": "above",
            "above_value": 5
        },
        "notification_channels": ["Notify DM 2ndline"],
        "notification_type": ["every", 60],
        "info": "5+ requests taking 10+ seconds from the production router in the last minute"
    },
    {
        "name": "Production Router slow requests (5-10 seconds)",
        "metric": "cloudwatch.request_time_buckets.production.router.request_time_bucket_8.sum",
        "alert_criteria": {
            "type": "above",
            "above_value": 5
        },
        "notification_channels": ["Notify DM 2ndline"],
        "notification_type": ["every", 60],
        "info": "5+ requests taking 5-10 seconds from the production router in the last minute"
    },
]


def get_missing_logs_alert_json(environment, app):
    """
    For a given environment and application, return the JSON required to set up an alert that will trigger if either
    no nginx log event metrics or no application log event metrics are received for 15 minutes.

    We use an OR statement for either nginx or application logs so we can save on the number of alerts we are using. A
    developer seeing this alert will need to manually diagnose if it is just one or both of the log types that have
    stopped. Note, the router app only has nginx logs so we do not need to do this for the router.

    These alerts are not editable through the Hosted Graphite GUI as referenced in the API documentation at time of
    writing:

    `Our UI doesn’t fully support composites at the moment. As a result, composite alerts cannot be edited via the UI -
    it needs to be done via the API. The alert overview page (when you click the eye button on an alert) will only
    display one metric for the alert instead of all the metrics associated. However the alert notifications are working
    and will display the graph of the last metric that breached the alert threshold. So for example, if the alert is
    a && b, and a breaches the threshold, then a few minutes later b breaches it’s threshold, the alert notification
    will show the metric graph for b`

    Time period for alerting missing logs is set to 15 minutes. The smoke tests run every 5 minutes, this allows
    some wiggle room to avoid false positives arising from a delay in shipping the metrics from Cloudwatch.
    """
    data = {
        "name": "{} {} missing logs".format(environment, app),
        "metric": "cloudwatch.incoming_log_events.{}.{}.nginx_logs.sum".format(environment, app),
        "alert_criteria": {
            "type": "missing",
            "time_period": 15,
        },
        "notification_channels": ["Notify DM 2ndline"],  # Hardcoded name, channel had been set up manually already
        "notification_type": ["every", 60],
        "info": """No incoming log events metrics for the last 15 minutes for the {} app. This could be either the \
application logs or the nginx logs or both. This could indicate either a problem with metric shipping to Hosted \
Graphite or that the logs are not being created.\nDO NOT MANUALLY EDIT - Set up through Hosted Graphite API so GUI may \
have inconsistencies. See HG alerting API for details""".format(app)
    }

    if app != "router":
        # The router app does not have application logs
        data.update({
            "additional_criteria": {
                "b": {
                    "metric": "cloudwatch.incoming_log_events.{}.{}.application_logs.sum".format(environment, app),
                    "type": "missing",
                    "time_period": 15,
                }
            },
            "expression": "a || b",
        })

    return data


def create_alert(api_key, alert):
    endpoint = "https://api.hostedgraphite.com/v2/alerts/"
    resp = requests.post(endpoint, auth=(api_key, ''), data=json.dumps(alert))
    resp.raise_for_status()


# No staging alert as we have a limit on how many alerts we can have and this will cover both the first step of our
# pipeline and also production
ALERT_ENVIRONMENTS = ["preview", "production"]
ALERT_APPS = [
    "api", "search-api", "admin-frontend", "buyer-frontend", "briefs-frontend", "brief-responses-frontend",
    "router", "supplier-frontend", "user-frontend"
]


def create_missing_logs_alerts(api_key):
    # TODO: Log any 409 failures (alert already present) and continue with next alert
    for environment in ALERT_ENVIRONMENTS:
        for app in ALERT_APPS:
            print("Creating missing logs alert for {} {}".format(environment, app))
            create_alert(api_key, get_missing_logs_alert_json(environment, app))


def create_alerts(api_key):
    # TODO: Log any 409 failures (alert already present) and continue with next alert
    for alert in ALERTS:
        print("Creating alert for {}".format(alert["name"]))
        create_alert(api_key, alert)
