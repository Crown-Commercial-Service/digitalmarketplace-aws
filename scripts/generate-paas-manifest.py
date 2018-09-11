#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

import click

sys.path.insert(0, '.')  # noqa

from dmaws.utils import load_file, template_string, merge_dicts, UndefinedError
from dmaws.variables import load_variables


def get_variables_from_command_line_or_environment(vars):
    cli_vars = []
    for v in vars:
        # get (option, value) tuple from `--var` flag
        v = tuple(v.split("=", maxsplit=1))

        # if they didn't specify on the command line, check the envvars
        if len(v) == 1:
            v = (v[0], os.getenv(v[0]))
            if v[1] is None:
                raise KeyError(v[0])

        cli_vars.append(v)

    return dict(cli_vars)


@click.command()
@click.argument('environment', nargs=1, type=click.Choice(['preview', 'staging', 'production']))
@click.argument('app', nargs=1)
@click.option('--out-file', '-o',
              help="Output file, if empty the template content is printed to the stdout")
@click.option('--vars-file', '-f', multiple=True, type=click.Path(exists=True),
              help="Load YAML or JSON variable file")
@click.option('--var', '-v', multiple=True, type=str,
              help="Specify variables on the command line. "
                   "Can be a key-value pair in the form option=value, "
                   "or the name of an environment variable."
              )
def paas_manifest(environment, app, vars_file, var, out_file):
    """Generate a PaaS manifest file from a Jinja2 template"""

    variables = load_variables(environment, vars_file, {
        'environment': environment,
        'app': app.replace('_', '-')
    })

    template_file = f"paas/{app}.j2"
    template_content = load_file(template_file)

    variables = merge_dicts(variables, variables[app])

    try:
        variables = merge_dicts(variables, get_variables_from_command_line_or_environment(var))
    except KeyError as e:
        sys.exit(
            f"""Error: Command line variable "--var '{e.args[0]}'" was not set by the flag"""
            """ and was not found in environment variables. Please check your environment is correctly configured."""
        )

    try:
        manifest_content = template_string(template_content, variables, templates_path='paas/')
    except UndefinedError as e:
        # the UndefinedError.message is usually something like "'VAR' is undefined"
        sys.exit(
            f"""Error: The template '{template_file}' thinks that the variable {e.message}."""
            """ Please check you have included all of the var files and command line vars that you need."""
        )

    if out_file is not None:
        with open(out_file, 'w') as f:
            f.write(manifest_content)
        os.chmod(out_file, 0o600)
    else:
        print(manifest_content)


if __name__ == "__main__":
    paas_manifest()
