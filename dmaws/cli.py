from functools import wraps

import click

from .context import pass_context


STAGES = [
    'development',
]


@click.group(chain=True)
@click.argument('stage', nargs=1, type=click.Choice(STAGES))
@click.argument('environment', nargs=1)
@pass_context
def main(ctx, stage, environment):
    ctx.load_variables(variables={
        'stage': stage,
        'environment': environment,
    })


def cli_command(cmd):
    """Common options for deployment commands."""
    @click.option('--app', '-a', multiple=True,
                  help="Only run given app stacks")
    @click.option('--vars-file', '-f', multiple=True,
                  type=click.Path(exists=True),
                  help="Load YAML or JSON extra variable file")
    @click.option('--var', '-v', multiple=True,
                  help="Set an extra variable")
    @click.option('--stacks-file', '-s', default='stacks.yml',
                  type=click.Path(exists=True),
                  help="Stack dependencies file")
    @click.option('--load-default-files/--skip-default-files', default=True,
                  help="Load user.yml file")
    @click.option('--dry-run', is_flag=True, default=False,
                  help="List tasks that would run without executing any of them")
    @pass_context
    @wraps(cmd)
    def wrapped(ctx, app, vars_file, var, stacks_file, load_default_files,
                dry_run, *args, **kwargs):
        if load_default_files:
            vars_file = [
                'vars/common.yml',
                'vars/{}.yml'.format(ctx.variables['stage']),
                'vars/user.yml',
            ] + list(vars_file)

        ctx.load_variables(files=vars_file, pairs=[v.split('=') for v in var])
        ctx.load_stacks(stacks_file)
        ctx.apps = [app_name.replace('-', '_') for app_name in app]
        ctx.dry_run = dry_run

        return cmd(ctx, *args, **kwargs)

    return wrapped


from .commands import *  # noqa


def cli():
    main(auto_envvar_prefix='DM_AWS')
