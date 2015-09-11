"""

Usage:
    scripts/find_slow_routes.py [--save-from-aws] <log_group> <log_stream>

"""
from datetime import datetime, timedelta
import boto3
import sys
import json
import os
from pandas import DataFrame
from docopt import docopt


def _call_aws(client, log_group_name, log_stream_name,
              start_time=None, next_token=None):
    print('call_aws', file=sys.stderr)
    kwargs = {
        'filterPattern': '',
        'logGroupName': log_group_name,
        'logStreamNames': [log_stream_name],
    }
    if start_time is not None:
        kwargs['startTime'] = int(start_time.timestamp() * 1000)
    elif next_token is not None:
        kwargs['nextToken'] = next_token

    return client.filter_log_events(**kwargs)


def read_data_from_aws(log_group_name, log_stream_name):
    start_time = datetime.now() - timedelta(days=7)
    filter_pattern = '{}'

    if log_group_name.startswith('preview'):
        profile = 'development'
    else:
        profile = 'production'
    session = boto3.session.Session(region_name='eu-west-1',
                                    profile_name=profile)
    client = session.client('logs')

    data = _call_aws(client,
                     log_group_name,
                     log_stream_name,
                     start_time=start_time)
    while True:
        events = map(parse_event_message, data['events'])
        events = filter(filter_no_time, events)
        events = filter(filter_not_json, events)
        yield from events
        if 'nextToken' not in data:
            break
        data = _call_aws(client,
                         log_group_name,
                         log_stream_name,
                         next_token=data['nextToken'])


def parse_event_message(event):
    try:
        event['message'] = json.loads(event['message'])
    except ValueError:
        pass
    return event


def save_data_from_aws(log_group_name, log_stream_name):
    file_path = get_file_path(log_group_name, log_stream_name)
    events = read_data_from_aws(log_group_name, log_stream_name)
    with open(file_path, 'w+') as f:
        for i, event in enumerate(events):
            if (i + 1) % 1000 == 0:
                print("Written {}, flushing".format(i), file=sys.stderr)
                f.flush()
            f.write(json.dumps(event) + "\n")


def load_data_from_file(filename):
    with open(filename) as f:
        for line in f:
            yield json.loads(line)


def parse_request_line(request):
    method, path, _ = request.split(' ')
    query = None
    if '?' in path:
        path, query = path.split('?', 1)
    return method, path, query


def parse_request_time(event_message):
    if 'requestTime' in event_message:
        return int(event_message['requestTime'] * 1000000)
    elif 'requestTimeMicro' in event_message:
        return event_message['requestTimeMicro']


def make_row(event):
    try:
        method, path, query = parse_request_line(event['message']['request'])
        return {
            'status': event['message']['status'],
            'requestMethod': method,
            'requestPath': path,
            'requestQuery': query,
            'requestTime': parse_request_time(event['message']),
            'userAgent': event['message']['userAgent'],
            'requestId': event['message']['requestId'],
        }
    except TypeError:
        print(event)
        raise


def filter_not_json(event):
    return isinstance(event['message'], dict)


def filter_no_time(event):
    if 'requestTime' in event['message']:
        return True
    return 'requestTimeMicro' in event['message']


def filter_non_dm_api(event):
    """Filter out user agents that are not the DM-API-Client

    They are all smoke tests or monitoring.
    """
    return event['message']['userAgent'].startswith('DM-API-Client')


def load_all_data(log_group_name, log_stream_name):
    events = load_data_from_file(
        get_file_path(log_group_name, log_stream_name))
    events = filter(filter_non_dm_api, events)
    events = filter(filter_no_time, events)
    events = filter(filter_not_json, events)

    return DataFrame(list(map(make_row, events)))


def load_99th_percentile(df):
    desc = df.describe(percentiles=[.50, .90, .95, .99])
    desc['requestTime'] /= 1000

    return df[df['requestTime'] >= (desc.loc['99%']['requestTime'] * 1000)]


def get_file_path(log_group_name, log_stream_name):
    base_dir = os.path.join(os.getcwd(), 'logdata', log_group_name)
    if not os.path.isdir(base_dir):
        os.makedirs(base_dir)
    return os.path.join(base_dir, log_stream_name + '.json')


def main():
    arguments = docopt(__doc__)

    log_group_name = arguments['<log_group>']
    log_stream_name = arguments['<log_stream>']

    if arguments['--save-from-aws']:
        save_data_from_aws(log_group_name, log_stream_name)
    else:
        all_data = load_all_data(log_group_name, log_stream_name)
        slow = load_99th_percentile(all_data)

        for route, count in slow['requestPath'].value_counts()[:5].iteritems():
            print(route, count)
            by_route = slow[slow['requestPath'] == route]
            for i, (rid, row) in enumerate(by_route.iterrows()):
                print("   {}   {:<8}   {}".format(row['requestId'],
                                                  row['requestTime'] / 1000,
                                                  row['requestQuery']))
                if i > 10:
                    break

            desc_by_route = all_data[
                all_data['requestPath'] == route
            ].describe(percentiles=[.50, .90, .99])
            desc_by_route['requestTime'] /= 1000
            print(desc_by_route)
            print("")


if __name__ == '__main__':
    main()
