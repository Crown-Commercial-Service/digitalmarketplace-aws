import os
import collections

import yaml
import jinja2
from jinja2.exceptions import TemplateSyntaxError, UndefinedError  # noqa
from jinja2.runtime import StrictUndefined


DEFAULT_TEMPLATES_PATH = 'cloudformation_templates/'


def read_yaml_file(path):
    with open(path) as f:
        return yaml.safe_load(f) or {}


def load_file(path):
    with open(path) as f:
        return f.read()


def merge_dicts(a, b):
    if not (isinstance(a, dict) and isinstance(b, dict)):
        raise ValueError("Error merging variables: '{}' and '{}'".format(
            type(a).__name__, type(b).__name__
        ))

    result = a.copy()
    for key, val in b.items():
        if isinstance(result.get(key), collections.Mapping):
            result[key] = merge_dicts(a[key], b[key])
        else:
            result[key] = val

    return result


def template(item, variables, **kwargs):
    variables = merge_dicts(variables, kwargs)

    if isinstance(item, (str, bytes)):
        varname = template_string(item, variables)
        return varname

    elif isinstance(item, collections.Sequence):
        return [template(i, variables) for i in item]

    elif isinstance(item, collections.Mapping):
        result = {}
        for (key, val) in item.items():
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


def template_string(string, variables, templates_path=None):
    """Perform template substitution.

    Args:
        string: the template
        variables: a dict of variables that the template can use

    Raises:
        TemplateSyntaxError: there is an issue with the template syntax.
        UndefinedError: the template could not find the value for a variable.
    """
    jinja_env = jinja2.Environment(
        trim_blocks=True,
        lstrip_blocks=True,
        undefined=StrictUndefined,
        loader=jinja2.FileSystemLoader(
            templates_path or DEFAULT_TEMPLATES_PATH
        )
    )

    # can raise TemplateSyntaxError
    template = jinja_env.from_string(string)

    # can raise UndefinedError
    return template.render(variables)


def mkdir_p(path):
    """
    Creates a nested directory structure (does nothing if the path already exists)
    http://stackoverflow.com/a/14364249
    """
    try:
        os.makedirs(path)
    except OSError:
        if not os.path.isdir(path):
            raise
