import pytest
from collections import namedtuple
from dmaws.syncdata import RDS
from .helpers import set_boto_response

AWS_REGION = 'eu-west-1'

DBInstance = namedtuple('DBInstance', ['id', 'endpoint'])


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
