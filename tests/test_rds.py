from collections import namedtuple

import pytest
import mock
import boto
from boto.rds.dbsnapshot import DBSnapshot as _DBSnapshot
from boto.rds.dbinstance import DBInstance as _DBInstance

from .helpers import set_boto_response

from dmaws.rds import RDS, RDSPostgresClient


AWS_REGION = 'eu-west-1'


class DBInstance(_DBInstance):
    def __init__(self, rds_conn, id, endpoint=None, status="available",
                 vpc_security_groups=None):
        super(DBInstance, self).__init__(rds_conn)
        self.id = id
        self.endpoint = endpoint or ("host1", "5432")
        self.status = status
        self.vpc_security_groups = vpc_security_groups or []


class DBSnapshot(_DBSnapshot):
    def __init__(self, rds_conn, id, status='available'):
        super(DBSnapshot, self).__init__(rds_conn)
        self.id = id
        self.status = status


SecurityGroup = namedtuple('SecurityGroup', ['id', 'name'])
SecurityGroupMembership = namedtuple('SecurityGroupMembership', ['vpc_group'])


class TestRDS(object):
    def test_init(self, rds_conn):
        assert RDS(AWS_REGION).conn == rds_conn

    @pytest.mark.parametrize("url,expected_id", [
        ("hostname1:5432/database", "db1"),
        ("hostname2:5432/other", "db2"),
        ("invalid", None),
        ("unknown:5432/database", None),
    ])
    def test_get_instance_by_url(self, rds_conn, url, expected_id):
        rds = RDS(AWS_REGION)
        rds_conn.get_all_dbinstances.return_value = [
            DBInstance(rds_conn, 'db1', ('hostname1', '5432')),
            DBInstance(rds_conn, 'db2', ('hostname2', '5432')),
        ]

        instance = rds.get_instance(url=url)
        if expected_id is None:
            assert instance is None
        else:
            assert instance.id == expected_id

    @pytest.mark.parametrize("id,expected_id", [
        ("db1", "db1"),
        ("db2", "db2"),
        ("db3", None),
    ])
    def test_get_instance_by_id(self, rds_conn, id, expected_id):
        rds = RDS(AWS_REGION)
        rds_conn.get_all_dbinstances.return_value = [
            DBInstance(rds_conn, 'db1', ('hostname1', '5432')),
            DBInstance(rds_conn, 'db2', ('hostname2', '5432')),
        ]

        instance = rds.get_instance(id=id)
        if expected_id is None:
            assert instance is None
        else:
            assert instance.id == expected_id

    def test_create_new_snapshot(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.get_all_dbsnapshots.side_effect = boto.exception.BotoServerError(404, "Not found")
        rds_conn.create_dbsnapshot.return_value = DBSnapshot(rds_conn, "snapshot_id")

        rds.create_new_snapshot("snapshot_id", "instance_id")

        rds_conn.create_dbsnapshot.assert_called_once_with("snapshot_id", "instance_id")
        assert not rds_conn.delete_dbsnapshot.called

    def test_existing_snapshot_is_deleted_if_it_exists(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.get_all_dbsnapshots.return_value = [DBSnapshot(rds_conn, 'snapshot_id')]
        rds_conn.create_dbsnapshot.return_value = DBSnapshot(rds_conn, 'snapshot_id')

        rds.create_new_snapshot("snapshot_id", "instance_id")

        rds_conn.get_all_dbsnapshots.assert_called_once_with("snapshot_id")
        rds_conn.delete_dbsnapshot.assert_called_once_with("snapshot_id")
        rds_conn.create_dbsnapshot.assert_called_once_with("snapshot_id", "instance_id")

    @mock.patch('time.sleep')
    def test_create_new_snapshot_blocks_until_complete(self, sleep, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.get_all_dbsnapshots.side_effect = [
            boto.exception.BotoServerError(404, "Not found"),
            [DBSnapshot(rds_conn, "snapshot_id", "creating")],
            [DBSnapshot(rds_conn, "snapshot_id", "available")],
        ]
        rds_conn.create_dbsnapshot.return_value = DBSnapshot(rds_conn, "snapshot_id", "creating")

        rds.create_new_snapshot("snapshot_id", "instance_id")

        assert rds_conn.get_all_dbsnapshots.call_count == 3

    def test_delete_snapshot(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds.delete_snapshot("snapshot_id")

        rds_conn.delete_dbsnapshot.assert_called_once_with("snapshot_id")

    def test_create_new_security_group(self, ec2_conn):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = []
        ec2_conn.create_security_group.return_value = SecurityGroup('sg1', 'sg-name')

        security_group = rds.create_new_security_group('sg-name', ['ip1'], 'vpcid')

        assert security_group.id == 'sg1'
        assert security_group.name == 'sg-name'

        assert not ec2_conn.delete_security_group.called
        ec2_conn.create_security_group.assert_called_once_with(
            'sg-name', mock.ANY,
            vpc_id='vpcid')
        ec2_conn.authorize_security_group.assert_called_once_with(
            ip_protocol='tcp', from_port=5432, to_port=5432,
            cidr_ip='ip1', group_id='sg1')

    def test_create_new_security_group_deletes_existing_security_group(self, ec2_conn):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = [SecurityGroup('sg1', 'sg-name')]
        ec2_conn.create_security_group.return_value = SecurityGroup('sg1', 'sg-name')

        rds.create_new_security_group('sg-name', ['ip1'], 'vpcid')

        ec2_conn.delete_security_group.assert_called_with('sg-name')

    def test_create_new_security_group_does_not_delete_security_groups_with_other_names(self, ec2_conn):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = [SecurityGroup('sg1', 'sg-bad')]
        ec2_conn.create_security_group.return_value = SecurityGroup('sg1', 'sg-name')

        rds.create_new_security_group('sg-name', ['ip1'], 'vpcid')

        assert not ec2_conn.delete_security_group.called

    def test_create_new_security_group_adds_multiple_rules(self, ec2_conn):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = []
        ec2_conn.create_security_group.return_value = SecurityGroup('sg1', 'sg-name')

        security_group = rds.create_new_security_group('sg-name', ['ip1', 'ip2'], 'vpcid')

        ec2_conn.authorize_security_group.call_args_list == [
            mock.call(ip_protocol='tcp', from_port=5432, to_port=5432,
                      cidr_ip='ip1', group_id='sg1'),
            mock.call(ip_protocol='tcp', from_port=5432, to_port=5432,
                      cidr_ip='ip2', group_id='sg1'),
        ]

    def test_restore_instance_from_snapshot(self, rds_conn):
        rds = RDS(AWS_REGION)
        rds.allow_access_to_instance = mock.Mock()
        rds.delete_instance_if_found = mock.Mock()

        instance = DBInstance(rds_conn, "instance_id")
        rds.allow_access_to_instance.return_value = instance
        rds_conn.restore_dbinstance_from_dbsnapshot.return_value = instance

        instance = rds.restore_instance_from_snapshot(
            "snapshot_id", "instance_id",
            dev_user_ips=['anip'],
            vpc_id='vpcid')

        assert instance.id == "instance_id"
        assert instance.status == "available"
        rds_conn.restore_dbinstance_from_dbsnapshot("snapshot_id", "instance_id", "db.t2.micro", multi_az=False)
        rds.allow_access_to_instance.assert_called_once_with(instance, 'exportdata-dev-access', ['anip'], 'vpcid')

    @mock.patch('time.sleep')
    def test_restore_instance_from_snapshot_blocks_until_restore_is_complete(self, sleep, rds_conn):
        rds = RDS(AWS_REGION)
        rds.allow_access_to_instance = mock.Mock()
        rds.delete_instance_if_found = mock.Mock()

        rds.allow_access_to_instance.return_value = DBInstance(rds_conn, "instance_id")
        rds_conn.restore_dbinstance_from_dbsnapshot.return_value = DBInstance(
            rds_conn, "instance_id", status="creating")
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, "instance_id", status="creating")],
            [DBInstance(rds_conn, "instance_id", status="available")],
        ]

        instance = rds.restore_instance_from_snapshot(
            "snapshot_id", "instance", ["ip1"], "vpcid")

        assert instance.status == "available"
        assert rds_conn.get_all_dbinstances.call_count == 2

    @pytest.mark.parametrize("get_all_db_instances_side_effect, delete_instance_call_count", [
        (boto.exception.BotoServerError(404, "Not found"), 0),
        ([[DBInstance(mock.Mock(), "instance_id", status="available")]], 1)
    ])
    def test_restore_instance_from_snapshot_existing_instance_is_deleted_if_it_exists(
        self, rds_conn, get_all_db_instances_side_effect, delete_instance_call_count
    ):
        rds = RDS(AWS_REGION)
        rds.allow_access_to_instance = mock.Mock()
        rds.delete_instance = mock.Mock()

        instance = DBInstance(rds_conn, "instance_id")
        rds_conn.get_all_dbinstances.side_effect = get_all_db_instances_side_effect
        rds.allow_access_to_instance.return_value = instance
        rds_conn.restore_dbinstance_from_dbsnapshot.return_value = instance

        instance = rds.restore_instance_from_snapshot(
            "snapshot_id", "instance_id",
            dev_user_ips=['anip'],
            vpc_id='vpcid')

        assert instance.id == "instance_id"
        assert instance.status == "available"
        rds_conn.restore_dbinstance_from_dbsnapshot("snapshot_id", "instance_id", "db.t2.micro", multi_az=False)
        rds.allow_access_to_instance.assert_called_once_with(instance, 'exportdata-dev-access', ['anip'], 'vpcid')
        assert rds.delete_instance.call_count == delete_instance_call_count

    @mock.patch('time.sleep')
    def test_delete_instance(self, sleep, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.delete_dbinstance.return_value = DBInstance(rds_conn, "instance_id", status="deleting")
        rds_conn.get_all_dbinstances.side_effect = boto.exception.BotoServerError(404, "Not found")

        rds.delete_instance("instance_id")

        rds_conn.delete_dbinstance.assert_called_once_with("instance_id", skip_final_snapshot=True)

    @mock.patch('time.sleep')
    def test_delete_instance_blocks_until_complete(self, sleep, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.delete_dbinstance.return_value = DBInstance(rds_conn, "instance_id", status="deleting")
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, "instance_id", status="deleting")],
            [DBInstance(rds_conn, "instance_id", status="deleting")],
            boto.exception.BotoServerError(404, "Not found"),
        ]

        rds.delete_instance("instance_id")

        rds_conn.delete_dbinstance.assert_called_once_with("instance_id", skip_final_snapshot=True)
        assert rds_conn.get_all_dbinstances.call_count == 3

    def test_allow_access_to_instance(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = []
        ec2_conn.create_security_group.return_value = SecurityGroup('sg-1', 'sg#1')
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='modifying')
        rds_conn.get_all_dbinstances.return_value = [DBInstance(rds_conn, 'ins-1', status='available')]

        rds.allow_access_to_instance(
            DBInstance(rds_conn, 'ins-1'), 'sg#1',
            ['ip-one'], 'vpcid')

        ec2_conn.create_security_group.assert_called_once_with(
            'sg#1', mock.ANY, vpc_id='vpcid')
        ec2_conn.authorize_security_group.assert_called_once_with(
            ip_protocol=mock.ANY, from_port=mock.ANY, to_port=mock.ANY,
            cidr_ip='ip-one', group_id='sg-1')
        rds_conn.modify_dbinstance.assert_called_once_with(
            'ins-1', vpc_security_groups=['sg-1'], apply_immediately=True)

    def test_allow_access_revokes_existing_access_first(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)
        rds.revoke_access_to_instance = mock.Mock()

        instance = DBInstance(rds_conn, 'ins-1')

        ec2_conn.get_all_security_groups.return_value = [SecurityGroup('sg-1', 'sg#1')]
        rds.revoke_access_to_instance.return_value = DBInstance(rds_conn, 'ins-1')
        ec2_conn.create_security_group.return_value = SecurityGroup('sg-1', 'sg#1')
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='modifying')
        rds_conn.get_all_dbinstances.return_value = [DBInstance(rds_conn, 'ins-1', status='available')]

        rds.allow_access_to_instance(
            instance, 'sg#1',
            ['ip-one'], 'vpcid')

        rds.revoke_access_to_instance.assert_called_with(
            instance, SecurityGroup('sg-1', 'sg#1'))
        ec2_conn.delete_security_group.assert_called_with('sg#1')

    def test_allow_access_waits_for_instance_to_become_unavailable_after_modify(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = []
        ec2_conn.create_security_group.return_value = SecurityGroup('sg-1', 'sg#1')
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='available')
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, 'ins-1', status='available')],
            [DBInstance(rds_conn, 'ins-1', status='modifying')],
            [DBInstance(rds_conn, 'ins-1', status='modifying')],
            [DBInstance(rds_conn, 'ins-1', status='available')],
        ]

        rds.allow_access_to_instance(
            DBInstance(rds_conn, 'ins-1'), 'sg#1',
            ['ip-one'], 'vpcid')

        assert rds_conn.get_all_dbinstances.call_count == 4

    def test_allow_access_does_not_wait_for_instance_to_become_unavailable_indefinitely(self, rds_conn, ec2_conn,
                                                                                        sleep):
        rds = RDS(AWS_REGION)

        ec2_conn.get_all_security_groups.return_value = []
        ec2_conn.create_security_group.return_value = SecurityGroup('sg-1', 'sg#1')
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='available')
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, 'ins-1', status='available')],
        ] * 30

        rds.allow_access_to_instance(
            DBInstance(rds_conn, 'ins-1'), 'sg#1',
            ['ip-one'], 'vpcid')

        assert rds_conn.get_all_dbinstances.call_count == 20

    def test_revoke_access_to_instance(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)

        vpc_security_groups = [
            SecurityGroupMembership('sg-1'),
            SecurityGroupMembership('sg-2'),
        ]
        instance = DBInstance(rds_conn, 'inst-1', vpc_security_groups=vpc_security_groups)
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='modifying')
        rds_conn.get_all_dbinstances.return_value = [DBInstance(rds_conn, 'ins-1', status='available')]

        rds.revoke_access_to_instance(instance, SecurityGroup('sg-1', 'sgname'))

        rds_conn.modify_dbinstance.assert_called_once_with(
            'inst-1', vpc_security_groups=['sg-2'], apply_immediately=True)

    def test_revoke_access_noops_if_security_group_is_not_on_instance(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)

        vpc_security_groups = [
            SecurityGroupMembership('sg-2'),
        ]
        instance = DBInstance(rds_conn, 'inst-1', vpc_security_groups=vpc_security_groups)
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='modifying')
        rds_conn.get_all_dbinstances.return_value = [DBInstance(rds_conn, 'ins-1', status='available')]

        rds.revoke_access_to_instance(instance, SecurityGroup('sg-1', 'sgname'))

        assert not rds_conn.modify_dbinstance.called

    def test_revoke_access_adds_default_security_group_if_list_would_be_empty(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)

        vpc_security_groups = [
            SecurityGroupMembership('sg-1'),
        ]
        instance = DBInstance(rds_conn, 'inst-1', vpc_security_groups=vpc_security_groups)
        ec2_conn.get_all_security_groups.return_value = [SecurityGroup('default-id', 'default')]
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='modifying')
        rds_conn.get_all_dbinstances.return_value = [DBInstance(rds_conn, 'ins-1', status='available')]

        rds.revoke_access_to_instance(instance, SecurityGroup('sg-1', 'sgname'))

        rds_conn.modify_dbinstance.assert_called_once_with(
            'inst-1', vpc_security_groups=['default-id'], apply_immediately=True)

    def test_revoke_access_waits_for_instance_to_become_unavailable_after_modify(self, rds_conn, ec2_conn, sleep):
        rds = RDS(AWS_REGION)

        vpc_security_groups = [
            SecurityGroupMembership('sg-1'),
            SecurityGroupMembership('sg-2'),
        ]
        instance = DBInstance(rds_conn, 'inst-1', vpc_security_groups=vpc_security_groups)
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='available')
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, 'ins-1', status='modifying')],
            [DBInstance(rds_conn, 'ins-1', status='available')],
        ]

        rds.revoke_access_to_instance(instance, SecurityGroup('sg-1', 'sgname'))

        assert rds_conn.get_all_dbinstances.call_count == 2

    def test_revoke_access_does_not_wait_for_instance_to_become_unavailable_indefinitely(self, rds_conn, ec2_conn,
                                                                                         sleep):
        rds = RDS(AWS_REGION)

        vpc_security_groups = [
            SecurityGroupMembership('sg-1'),
            SecurityGroupMembership('sg-2'),
        ]
        instance = DBInstance(rds_conn, 'inst-1', vpc_security_groups=vpc_security_groups)
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, 'ins-1', status='available')
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, 'ins-1', status='available')],
        ] * 30

        rds.revoke_access_to_instance(instance, SecurityGroup('sg-1', 'sgname'))

        assert rds_conn.get_all_dbinstances.call_count == 20


@mock.patch('psycopg2.connect')
class TestRDSPostgresClient(object):
    def test_from_boto(self, pg_connect):
        pg_connection = pg_connect.return_value

        instance = DBInstance(None, 'instance_id')
        RDSPostgresClient.from_boto(instance, "db_name", "db_user", "db_password").cursor

        pg_connect.assert_called_once_with(**dict(
            host='host1',
            port='5432',
            database='db_name',
            user='db_user',
            password='db_password',
        ))

    def test_from_url(self, pg_connect):
        pg_connection = pg_connect.return_value

        RDSPostgresClient.from_url("host1:port/the_db", "db_user", "db_password").cursor

        pg_connect.assert_called_once_with(**dict(
            host="host1",
            port="port",
            database="the_db",
            user="db_user",
            password="db_password",
        ))

    def create_client(self, pg_connect):
        pg_connection = pg_connect.return_value
        pg_cursor = pg_connection.cursor.return_value

        client = RDSPostgresClient('host1', '5432', 'db_name', 'db_user', 'db_password')

        return pg_connection, pg_cursor, client

    def test_connect_not_called_if_cursor_not_accessed(self, pg_connect):
        pg_connection = pg_connect.return_value
        pg_cursor = pg_connection.cursor.return_value

        RDSPostgresClient('host1', '5432', 'db_name', 'db_user', 'db_password')

        assert not pg_connect.called

    def test_cursor(self, pg_connect):
        pg_connection, pg_cursor, client = self.create_client(pg_connect)

        client.cursor

        pg_connection.cursor.assert_called_once_with()

    def test_cursor_reuses_same_cursor(self, pg_connect):
        pg_connection, pg_cursor, client = self.create_client(pg_connect)

        client.cursor
        client.cursor

        pg_connection.cursor.assert_called_once_with()

    def test_commit(self, pg_connect):
        pg_connection, pg_cursor, client = self.create_client(pg_connect)

        client.cursor
        client.commit()

        pg_connection.cursor.assert_called_once_with()
        pg_connection.commit.assert_called_once_with()

    def test_close(self, pg_connect):
        pg_connection, pg_cursor, client = self.create_client(pg_connect)

        client.cursor
        client.close()

        pg_cursor.close.assert_called_once_with()
        pg_connection.close.assert_called_once_with()

    def test_dump(self, pg_connect, run_cmd):
        pg_connection, pg_cursor, client = self.create_client(pg_connect)

        client.dump("output.sql")

        run_cmd.assert_called_once_with([
            "pg_dump", "-cb", "-d", "postgres://db_user:db_password@host1:5432/db_name", "-f", "output.sql"
        ], logger=mock.ANY, ignore_errors=True)
