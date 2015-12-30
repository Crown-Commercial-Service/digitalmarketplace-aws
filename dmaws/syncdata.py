import boto.rds


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

        self.conn.create_dbsnapshot(snapshot_id, instance_id)

    def delete_snapshot(self, snapshot_id):
        self.conn.delete_dbsnapshot(snapshot_id)
