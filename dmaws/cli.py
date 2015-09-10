from functools import wraps
import os
import sys

import click

from .context import pass_context
from .utils import CalledProcessError


STAGES = [
    'development',
    'preview',
    'staging',
    'production',
    'ci',
]


@click.group()
@click.argument('stage', nargs=1, type=click.Choice(STAGES))
@click.argument('environment', nargs=1)
@pass_context
def main(ctx, stage, environment):
    ctx.stage = stage
    ctx.environment = environment


def cli_command(cmd_name, max_apps=-1):
    """Common options for deployment commands."""

    def wrapper(cmd):
        @main.command(cmd_name)
        @click.option('--vars-file', '-f', multiple=True,
                      type=click.Path(exists=True),
                      help="Load YAML or JSON extra variable file")
        @click.option('--var', '-v', multiple=True,
                      help="Set an extra variable")
        @click.option('--stacks-file', '-s', default='stacks.yml',
                      type=click.Path(exists=True),
                      help="Stack dependencies file")
        @click.option('--load-default-files/--skip-default-files',
                      default=True,
                      help="Load user.yml file")
        @click.option(
            '--dry-run', is_flag=True, default=False,
            help="List tasks that would run without executing any of them"
        )
        @pass_context
        @wraps(cmd)
        def wrapped(ctx, vars_file, var, stacks_file, load_default_files,
                    dry_run, app=None, *args, **kwargs):
            if load_default_files:
                default_vars_files = [
                    'vars/common.yml',
                    'vars/{}.yml'.format(ctx.stage),
                ]
                if os.path.exists('vars/user.yml'):
                    default_vars_files.append('vars/user.yml')
                vars_file = default_vars_files + list(vars_file)

            ctx.load_variables(files=vars_file,
                               pairs=[v.split('=') for v in var])
            ctx.load_stacks(stacks_file)
            ctx.add_apps(app)
            ctx.dry_run = dry_run

            try:
                return cmd(ctx, *args, **kwargs)
            except CalledProcessError as e:
                ctx.log("%s:\n\n%s", str(e), e.output)
                sys.exit(1)

        if max_apps:
            wrapped = click.argument('app', nargs=max_apps)(wrapped)

        return wrapped

    return wrapper


from .commands import *  # noqa


def cli():
    main(auto_envvar_prefix='DM_AWS')
