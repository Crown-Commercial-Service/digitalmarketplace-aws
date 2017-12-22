#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Description:
    To add

Usage:
    scripts/create-hosted-graphite-dashboards.py <hosted_graphite_api_key>

Example:
    scripts/create-hosted-graphite-dashboards.py apikey
"""

import os
import sys

import requests
from docopt import docopt

sys.path.insert(0, '.')  # noqa


def generate_dashboards(api_key):
    endpoint = "https://api.hostedgraphite.com/api/v2/grafana/dashboards/"
    path = os.path.join(os.path.dirname(__file__), "../grafana/")

    for filename in os.listdir(path):
        with open(path + filename) as fp:
            resp = requests.put(endpoint, auth=(api_key, ''), data=fp.read())
            resp.raise_for_status()


if __name__ == "__main__":
    arguments = docopt(__doc__)
    generate_dashboards(arguments['<hosted_graphite_api_key>'])
