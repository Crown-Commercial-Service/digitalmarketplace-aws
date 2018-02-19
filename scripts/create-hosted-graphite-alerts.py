#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Description:
    Sets up alerts for missing logs for our applications using the Hosted Graphite alerting API

    https://www.hostedgraphite.com/docs/alerting/alerting_api.html

    Note, this script has been used as a one off to create alerts. If a user wishes to edit existing alerts than this
    will likely not work as there will be a 409 (conflict) response returned. As this is likely a rare process, it is
    advised to manually delete alerts that you wish to replace before rerunning this script.

Usage:
    scripts/create-hosted-graphite-alerts.py <hosted_graphite_api_key>

Example:
    scripts/create-hosted-graphite-alerts.py apikey
"""
import json

import requests
from docopt import docopt


# No staging alert as we have a limit on how many alerts we can have and this will cover both the first step of our
# pipeline and also production
ENVIRONMENTS = ["preview", "production"]

APPS = ["api", "search-api", "admin-frontend", "buyer-frontend", "briefs-frontend", "brief-responses-frontend",
        "router", "supplier-frontend", "user-frontend"]


def get_alert_json(environment, app):
    """
    For a given environment and application, return the JSON required to set up an alert that will trigger if either
    no nginx log event metrics or no application log event metrics are received for 10 minutes.

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
    """
    data = {
        "name": "{} {} missing logs".format(environment, app),
        "metric": "cloudwatch.incoming_log_events.{}.{}.nginx_logs.sum".format(environment, app),
        "alert_criteria": {
            "type": "missing",
            "time_period": 10,  # 10 minutes chosen as smoke tests should be triggering logs every 5 minutes
        },
        "notification_channels": ["Notify DM 2ndline"],  # Hardcoded name, channel had been set up manually already
        "notification_type": ["every", 60],
        "info": """No incoming log events metrics for the last 10 minutes for the {} app. This could be either the \
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
                    "time_period": 10,
                }
            },
            "expression": "a || b",
        })

    return data


def generate_alerts(api_key):
    endpoint = "https://api.hostedgraphite.com/v2/alerts/"
    for environment in ENVIRONMENTS:
        for app in APPS:
            print("Creating missing logs alert for {} {}".format(environment, app))
            alert = get_alert_json(environment, app)
            resp = requests.post(endpoint, auth=(api_key, ''), data=json.dumps(alert))
            resp.raise_for_status()


if __name__ == "__main__":
    arguments = docopt(__doc__)
    generate_alerts(arguments['<hosted_graphite_api_key>'])
