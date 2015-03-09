import collections

import yaml
import jinja2
from jinja2.runtime import StrictUndefined


def read_yaml_file(path):
    with open(path) as f:
        return yaml.load(f)


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


def template(item, variables):
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
