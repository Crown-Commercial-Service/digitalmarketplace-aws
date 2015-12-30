from collections import namedtuple

import pytest
import boto

from .helpers import set_boto_response

from dmaws.syncdata import RDS


AWS_REGION = 'eu-west-1'

DBInstance = namedtuple('DBInstance', ['id', 'endpoint'])
DBSnapshot = namedtuple('DBSnapshot', ['id'])


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
            DBInstance('db1', ('hostname1', '5432')),
            DBInstance('db2', ('hostname2', '5432')),
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
            DBInstance('db1', ('hostname1', '5432')),
            DBInstance('db2', ('hostname2', '5432')),
        ]

        instance = rds.get_instance(id=id)
        if expected_id is None:
            assert instance is None
        else:
            assert instance.id == expected_id

    def test_create_new_snapshot(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.get_all_dbsnapshots.side_effect = boto.exception.BotoServerError(404, "Not found")
        rds.create_new_snapshot("snapshot_id", "instance_id")

        rds_conn.create_dbsnapshot.assert_called_once_with("snapshot_id", "instance_id")
        assert not rds_conn.delete_dbsnapshot.called

    def test_existing_snapshot_is_deleted_if_it_exists(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds_conn.get_all_dbsnapshots.return_value = [
            DBSnapshot('snapshot_id')
        ]

        rds.create_new_snapshot("snapshot_id", "instance_id")

        rds_conn.get_all_dbsnapshots.assert_called_once_with("snapshot_id")
        rds_conn.delete_dbsnapshot.assert_called_once_with("snapshot_id")
        rds_conn.create_dbsnapshot.assert_called_once_with("snapshot_id", "instance_id")

    def test_delete_snapshot(self, rds_conn):
        rds = RDS(AWS_REGION)

        rds.delete_snapshot("snapshot_id")

        rds_conn.delete_dbsnapshot.assert_called_once_with("snapshot_id")
