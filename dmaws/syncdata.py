import time

import boto.rds
import psycopg2

from . import utils


class RDS(object):
    def __init__(self, region, logger=None, profile_name=None):
        self.conn = boto.rds.connect_to_region(
            region,
            profile_name=profile_name)
        self.log = logger or (lambda *args, **kwargs: None)

    def get_instance(self, url=None, id=None):
        instances = self.conn.get_all_dbinstances()
        predicate = lambda instance: False
        if url is not None:
            predicate = lambda instance: instance.endpoint[0] == url.split(':')[0]
        elif id is not None:
            predicate = lambda instance: instance.id == id
        return next(filter(predicate, instances), None)

    def create_new_snapshot(self, snapshot_id, instance_id):
        """Create a new RDS snapshot deleting the existing one if there
        """
        try:
            self.conn.get_all_dbsnapshots(snapshot_id)
            self.conn.delete_dbsnapshot(snapshot_id)
        except boto.exception.BotoServerError as e:
            if e.status != 404:
                raise

        snapshot = self.conn.create_dbsnapshot(snapshot_id, instance_id)

        self._wait_for_available(snapshot, "snapshot", "creating")

    def delete_snapshot(self, snapshot_id):
        self.conn.delete_dbsnapshot(snapshot_id)

    def restore_instance_from_snapshot(self, snapshot_id, instance_id, vpc_security_groups):
        instance = self.conn.restore_dbinstance_from_dbsnapshot(
            snapshot_id, instance_id,
            "db.t2.micro",
            multi_az=False)

        self._wait_for_available(instance, "RDS instance", "creating")

        instance = self.conn.modify_dbinstance(
            instance_id,
            vpc_security_groups=vpc_security_groups)

        self._wait_for_available(instance, "RDS instance", "modifying")

        return instance

    def delete_instance(self, instance_id):
        instance = self.conn.delete_dbinstance(instance_id, skip_final_snapshot=True)
        self._wait_for_delete(instance, "RDS instance")

    def _wait_for_available(self, target, name, action):
        while target.status != "available":
            self.log("Waiting for {} to be available after {}".format(name, action))
            time.sleep(20)
            target.update()

    def _wait_for_delete(self, target, name):
        try:
            while target.status == "deleting":
                self.log("Waiting while deleting {}".format(name))
                time.sleep(20)
                target.update()
        except boto.exception.BotoServerError as e:
            if e.status != 404:
                raise


class RDSPostgresClient(object):
    @staticmethod
    def from_boto(instance, database, user, password, logger=None):
        return RDSPostgresClient(
            instance.endpoint[0], instance.endpoint[1],
            database, user, password, logger)

    def __init__(self, host, port, database, user, password, logger=None):
        self.db_params = dict(
            host=host,
            port=port,
            database=database,
            user=user,
            password=password,
        )
        self._connection = psycopg2.connect(**self.db_params)
        self._cursor = None

        self.log = logger or (lambda *args, **kwargs: None)

    @property
    def cursor(self):
        if not self._cursor:
            self._cursor = self._connection.cursor()

        return self._cursor

    def execute(self, sql):
        return self.cursor.execute(sql)

    def commit(self):
        self._connection.commit()

    def close(self):
        if self._cursor:
            self._cursor.close()
        self._connection.close()

    def dump(self, output_path):
        db_path = "postgres://{user}:{password}@{host}:{port}/{database}".format(**self.db_params)
        utils.run_cmd([
            'pg_dump', '-cb', '-d', db_path, '-f', output_path
        ], logger=self.log, ignore_errors=True)
