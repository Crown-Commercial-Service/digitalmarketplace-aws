#!/usr/bin/env python
# encoding: utf-8

import os
import json
import subprocess
from collections import namedtuple
from functools import wraps

import click


STAGES = [
    'development',
]


_Params = namedtuple('_Params', ['variables', 'options', 'tags'])


class PlaybookParams(_Params):
    def add(self, variables=None, options=None, tags=None):
        params = self._replace(
            variables=self.variables.copy(),
            options=self.options + list(options or []),
            tags=self.tags + list(tags or [])
        )
        params.variables.update(variables or {})

        return params


def run_cmd(args, env=None):
    cmd_env = os.environ.copy()
    cmd_env.update(env)
    cmd = subprocess.Popen(args, env=cmd_env)
    cmd.communicate()


def run_playbook(playbook, hosts, params, basedir='playbooks/'):
    args = [
        'ansible-playbook',
        os.path.join(basedir, playbook + '.yml'),
        '-i',
        os.path.join(basedir, hosts),
    ]

    args.extend([
        '-e',
        json.dumps(params.variables)
    ])
    args.extend(params.options)

    tags_option = '--tags={}'.format(','.join(params.tags))

    if params.tags:
        args.append(tags_option)

    click.echo(subprocess.list2cmdline(args))

    run_cmd(args, {
        'ANSIBLE_CONFIG': os.path.join(basedir, 'ansible.cfg')
    })


@click.group(chain=True)
@click.argument('stage', nargs=1, type=click.Choice(STAGES))
@click.argument('environment', nargs=1)
@click.pass_context
def main(ctx, stage, environment):
    ctx.obj = ctx.obj.add(variables={
        'stage_name': stage,
        'environment_name': environment,
    })


def deploy_command(f):
    """Common options for deployment commands."""
    @click.option('--tag', '-t', multiple=True,
                  help="Only run tasks with given tag")
    @click.option('--extra', '-e', multiple=True,
                  help="Set an extra variable (key=value or YAML/JSON string)")
    @click.option('--load-user-file/--skip-user-file', default=True,
                  help="Load user.yml file")
    @click.option('--vars-file', '-f', multiple=True,
                  type=click.Path(exists=True),
                  help="Load YAML or JSON extra variable file")
    @click.pass_context
    @wraps(f)
    def wrapped(ctx, tag, extra, load_user_file, vars_file, *args, **kwargs):
        if load_user_file:
            vars_file = ['user.yml'] + list(vars_file)
        file_options = sum([['-e', '@{}'.format(v)] for v in vars_file], [])
        extra_vars_options = sum([['-e', e] for e in extra], [])
        ctx.obj = ctx.obj.add(
            tags=tag,
            options=file_options + extra_vars_options
        )
        return f(ctx, *args, **kwargs)

    return wrapped


@main.command('setup')
@deploy_command
@click.option('--dev-access', '-d', is_flag=True, default=False,
              help="Open service ports for access from user_cidr_ip")
def setup_cmd(ctx, dev_access):
    """Create AWS environment and launch instances"""

    params = ctx.obj.add(variables={
        'dev_access_state': 'present' if dev_access else 'absent',
    })

    run_playbook('setup', 'hosts', params)


@main.command('provision')
@deploy_command
def provision_cmd(ctx):
    """Provision EC2 instances"""
    run_playbook('provision', 'ec2.py', ctx.obj)


@main.command('teardown')
@deploy_command
@click.option('--with-base/--skip-base', default=False,
              help="Remove shared base resources")
def teardown_cmd(ctx, with_base):
    """Destroy AWS environment and terminate running instances."""

    params = ctx.obj.add(
        options=['--skip-tags=base'] if (not with_base) else None
    )

    run_playbook('teardown', 'hosts', params)


if __name__ == '__main__':
    main(obj=PlaybookParams({}, [], []), auto_envvar_prefix='AWS')
