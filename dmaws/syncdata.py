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
