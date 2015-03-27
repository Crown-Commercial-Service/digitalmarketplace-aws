import os
import subprocess
import collections

import yaml
import jinja2
from jinja2.runtime import StrictUndefined


def run_cmd(args, env=None, cwd=None, stdout=None):
    cmd_env = os.environ.copy()
    cmd_env.update(env or {})
    cmd = subprocess.Popen(args, env=cmd_env, cwd=cwd, stdout=stdout, stderr=subprocess.STDOUT)
    return cmd.communicate()[0]


def read_yaml_file(path):
    with open(path) as f:
        return yaml.load(f) or {}


def load_file(path):
    with open(path) as f:
        return f.read()


def dict_from_path(path, value):
    result = {}
    if isinstance(path, basestring):
        path = path.split('.')

    if not path:
        return value

    result[path[0]] = dict_from_path(path[1:], value)

    return result


def merge_dicts(a, b):
    if not (isinstance(a, dict) and isinstance(b, dict)):
        raise ValueError("Error merging variables: '{}' and '{}'".format(
            type(a).__name__, type(b).__name__
        ))

    result = a.copy()
    for key, val in b.iteritems():
        if isinstance(result.get(key), collections.Mapping):
            result[key] = merge_dicts(a[key], b[key])
        else:
            result[key] = val

    return result


def template(item, variables, **kwargs):
    variables = merge_dicts(variables, kwargs)

    if isinstance(item, basestring):
        varname = template_string(item, variables)
        return varname

    elif isinstance(item, collections.Sequence):
        return [template(i, variables) for i in item]

    elif isinstance(item, collections.Mapping):
        result = {}
        for (key, val) in item.iteritems():
            result[key] = template(val, variables)
        return result

    else:
        return item


class LazyTemplateMapping(object):
    def __init__(self, mapping, variables, **kwargs):
        self._mapping = mapping
        self._cache = {}
        self._variables = merge_dicts(variables, kwargs)

    def keys(self):
        return self._mapping.keys()

    def items(self):
        return [(key, self[key]) for key in self.keys()]

    def __getitem__(self, key):
        if key not in self._cache:
            self._cache[key] = template(self._mapping[key], self._variables)

        return self._cache[key]


def template_string(string, variables):
    jinja_env = jinja2.Environment(
        trim_blocks=True,
        undefined=StrictUndefined,
    )

    try:
        template = jinja_env.from_string(string)
    except jinja2.exceptions.TemplateSyntaxError, e:
        raise ValueError(u"Template error: {}".format(e))

    try:
        return template.render(variables)
    except jinja2.exceptions.UndefinedError, e:
        raise ValueError(u"Variable {} in '{}'".format(e, string))
