import sys
from boto import ec2


def get_instances(conn, environment):
    for reservation in conn.get_all_reservations():
        env_suffix = '-{}'.format(environment)
        if reservation.instances[0].tags['Name'].endswith(env_suffix):
            yield reservation.instances[0]


if __name__ == '__main__':
    environment = sys.argv[1]
    conn = ec2.connect_to_region('eu-west-1')

    for instance in get_instances(conn, environment):
        print(','.join([
            instance.id, instance.ip_address, instance.tags['Name']
        ]))
