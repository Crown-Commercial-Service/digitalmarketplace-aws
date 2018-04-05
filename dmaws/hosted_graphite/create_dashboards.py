import os
import sys

import requests

sys.path.insert(0, '.')  # noqa


def generate_dashboards(api_key):
    endpoint = "https://api.hostedgraphite.com/api/v2/grafana/dashboards/"
    path = os.path.join(os.path.dirname(__file__), "../grafana/")

    for filename in os.listdir(path):
        with open(path + filename) as fp:
            resp = requests.put(endpoint, auth=(api_key, ''), data=fp.read())
            resp.raise_for_status()
