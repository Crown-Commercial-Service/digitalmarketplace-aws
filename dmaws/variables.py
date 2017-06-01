import os
from .utils import merge_dicts, read_yaml_file


def load_variables(environment, vars_files=None, variables=None, load_default_files=True):
    variables = variables or {}
    for path in get_variables_files(environment, vars_files, load_default_files):
        variables = merge_dicts(variables, read_yaml_file(path))

    return variables


def get_variables_files(environment, vars_files=None, load_default_files=True):
    vars_files = vars_files or []
    if load_default_files:
        default_vars_files = [
            'vars/common.yml',
            'vars/{}.yml'.format(environment),
        ]
        if os.path.exists('vars/user.yml'):
            default_vars_files.append('vars/user.yml')
        vars_files = default_vars_files + list(vars_files)

    return vars_files
