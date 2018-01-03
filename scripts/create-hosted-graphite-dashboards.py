#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Description:
    This pushes dashboards defined in /grafana directory up to our hosted graphite.
    You can get the <hosted_graphite_api_key> from the "Account Home" page of hosted graphite.

    To change a dashboard a process you should follow is:
    1. Set "editable": true in one our existing JSON files
    2. Change the title (to avoid overwriting the existing dashboard as you try things out)
    3. Run this script
    4. Find the newly created dashboard in hosted graphite and make changes
    5. Export the JSON for the new dashboard (click settings cog, "View JSON") and overwrite the existing JSON file
    6. Set "editable": false and set the title back to the original one.  Remove the new "id" key from the exported JSON
    7. Run this script again
    8. Check you're happy with the new dashboard
    9. Delete the editable "test" dashboard you created in step 3 (click settings cog, "Delete dashboard")

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
