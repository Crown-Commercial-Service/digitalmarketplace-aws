from collections import namedtuple

import pytest
import mock
import boto
from boto.rds.dbsnapshot import DBSnapshot as _DBSnapshot
from boto.rds.dbinstance import DBInstance as _DBInstance

from .helpers import set_boto_response

from dmaws.syncdata import RDS


AWS_REGION = 'eu-west-1'


class DBInstance(_DBInstance):
    def __init__(self, rds_conn, id, endpoint=None, status="available"):
        super(DBInstance, self).__init__(rds_conn)
        self.id = id
        self.endpoint = endpoint or ("host1", "5432")
        self.status = status


class DBSnapshot(_DBSnapshot):
    def __init__(self, rds_conn, id, status='available'):
        super(DBSnapshot, self).__init__(rds_conn)
        self.id = id
        self.status = status


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

    def test_restore_instance_from_snapshot(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.restore_dbinstance_from_dbsnapshot.return_value = DBInstance(rds_conn, "instance_id")
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, "instance_id")

        instance = rds.restore_instance_from_snapshot("snapshot_id", "instance_id", ["sg1"])

        assert instance.id == "instance_id"
        assert instance.status == "available"
        rds_conn.modify_dbinstance.assert_called_once_with("instance_id", vpc_security_groups=["sg1"])

    @mock.patch('time.sleep')
    def test_restore_instance_from_snapshot_blocks_until_restore_is_complete(self, sleep, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.restore_dbinstance_from_dbsnapshot.return_value = DBInstance(
            rds_conn, "instance_id", status="creating")
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, "instance_id", status="creating")],
            [DBInstance(rds_conn, "instance_id", status="available")],
        ]
        rds_conn.modify_dbinstance.return_value = DBInstance(rds_conn, "instance_id")

        instance = rds.restore_instance_from_snapshot("snapshot_id", "instance", ["sg1"])

        assert instance.status == "available"
        assert rds_conn.get_all_dbinstances.call_count == 2

    @mock.patch('time.sleep')
    def test_restore_instance_from_snapshot_blocks_until_modify_is_complete(self, sleep, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.restore_dbinstance_from_dbsnapshot.return_value = DBInstance(
            rds_conn, "instance_id")
        rds_conn.modify_dbinstance.return_value = DBInstance(
            rds_conn, "instance_id", status="modifying")
        rds_conn.get_all_dbinstances.side_effect = [
            [DBInstance(rds_conn, "instance_id", status="modifying")],
            [DBInstance(rds_conn, "instance_id", status="available")],
        ]

        instance = rds.restore_instance_from_snapshot("snapshot_id", "instance", ["sg1"])

        assert instance.status == "available"
        assert rds_conn.get_all_dbinstances.call_count == 2

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
