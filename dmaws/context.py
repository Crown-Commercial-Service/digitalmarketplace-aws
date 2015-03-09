import os
import sys

import click

from .utils import merge_dicts, dict_from_path, read_yaml_file
from .stacks import Stack


class Context(object):
    def __init__(self, home=os.getcwd(), verbose=False, dry_run=False):
        self.home = home
        self.verbose = verbose
        self.dry_run = dry_run

        self.apps = None
        self.variables = {}
        self.stacks = {}
        self.create_dependencies = False

    def add_variables(self, variables):
        self.variables = merge_dicts(self.variables, variables)

    def add_variables_file(self, path):
        self.variables = merge_dicts(self.variables, read_yaml_file(path))

    def add_dotted_variable(self, path, value):
        self.variables = merge_dicts(self.variables,
                                     dict_from_path(path, value))

    def load_variables(self, files=None, pairs=None, variables=None):
        self.add_variables(variables or {})
        for path in (files or []):
            self.add_variables_file(path)
        for pair in (pairs or []):
            self.add_dotted_variable(*pair)

    def load_stacks(self, path):
        stacks = read_yaml_file(path)
        for key, val in stacks.iteritems():
            self.stacks[key] = Stack(**val)

    def log(self, msg, *args):
        """Logs a message to stderr."""
        if args:
            msg %= args
        click.echo(msg, file=sys.stderr)

    def vlog(self, msg, *args):
        """Logs a message to stderr only if verbose is enabled."""
        if self.verbose:
            self.log(msg, *args)


pass_context = click.make_pass_decorator(Context, ensure=True)
