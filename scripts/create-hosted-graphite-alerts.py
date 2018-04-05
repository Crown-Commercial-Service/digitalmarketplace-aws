#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Description:
    Sets up alerts for our applications using the Hosted Graphite alerting API

    https://www.hostedgraphite.com/docs/alerting/alerting_api.html

    Note, this script has been used as a one off to create alerts. If a user wishes to edit existing alerts than this
    will likely not work as there will be a 409 (conflict) response returned. As this is likely a rare process, it is
    advised to manually delete alerts that you wish to replace before rerunning this script.

Usage:
    scripts/create-hosted-graphite-alerts.py <hosted_graphite_api_key>

Example:
    scripts/create-hosted-graphite-alerts.py apikey
"""
from docopt import docopt
from dmaws.hosted_graphite.create_alerts import create_alerts, create_missing_logs_alerts


if __name__ == "__main__":
    api_key = docopt(__doc__)["<hosted_graphite_api_key>"]

    create_alerts(api_key)

    create_missing_logs_alerts(api_key)
