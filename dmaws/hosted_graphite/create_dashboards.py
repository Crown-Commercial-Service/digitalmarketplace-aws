import os
import sys

import requests

sys.path.insert(0, '.')  # noqa


def get_grafana_dashboard_folder():
    return os.path.join(os.path.dirname(__file__), "../grafana/")


def generate_dashboards(api_key):
    endpoint = "https://api.hostedgraphite.com/api/v2/grafana/dashboards/"
    path = get_grafana_dashboard_folder()

    for filename in os.listdir(path):
        with open(path + filename) as fp:
            resp = requests.put(endpoint, auth=(api_key, ''), data=fp.read())
            resp.raise_for_status()
