#!/usr/bin/env python
# encoding: utf-8

import os
import json
import subprocess

import click


STAGES = [
    'development',
]


def run_cmd(args, env=None):
    cmd_env = os.environ.copy()
    cmd_env.update(env)
    cmd = subprocess.Popen(args, env=cmd_env)
    cmd.communicate()


def run_playbook(playbook, hosts, options, variables,
                 tags=None, basedir='playbooks/'):
    args = [
        'ansible-playbook',
        os.path.join(basedir, playbook + '.yml'),
        '-i',
        os.path.join(basedir, hosts),
    ]

    args.extend(options)
    args.extend([
        '-e',
        json.dumps(variables)
    ])

    tags_option = '--tags={}'.format(','.join(tags))

    if tags:
        args.append(tags_option)

    click.echo(subprocess.list2cmdline(args))

    run_cmd(args, {
        'ANSIBLE_CONFIG': os.path.join(basedir, 'ansible.cfg')
    })


@click.group(chain=True)
@click.argument('stage', nargs=1, type=click.Choice(STAGES))
@click.argument('environment', nargs=1)
@click.option('--tag', '-t', multiple=True)
@click.pass_context
def main(ctx, stage, environment, tag):

    variables = {
        'stage_name': stage,
        'environment_name': environment,
    }

    ctx.obj['options'] = []
    ctx.obj['variables'] = variables
    ctx.obj['tags'] = tag


@main.command()
@click.pass_context
@click.option('--dev-access', '-d', is_flag=True, default=False,
              help="Open service ports for access from user_cidr_ip")
def setup(ctx, dev_access):
    """Create AWS environment and launch instances"""
    kwargs = ctx.obj.copy()
    kwargs['variables'] = ctx.obj['variables'].copy()
    kwargs['variables'].update({
        'dev_access_state': 'present' if dev_access else 'absent',
    })

    run_playbook('setup', 'hosts', **kwargs)


@main.command()
@click.pass_context
def provision(ctx):
    """Provision EC2 instances"""
    run_playbook('provision', 'ec2.py', **ctx.obj)


@main.command()
@click.pass_context
@click.option('--with-base/--skip-base', default=False,
              help="Remove shared base resources")
def teardown(ctx, with_base):
    """Destroy AWS environment and terminate running instances."""

    kwargs = ctx.obj.copy()
    if not with_base:
        kwargs['options'] = ctx.obj['options'] + ['--skip-tags=base']

    run_playbook('teardown', 'hosts', **kwargs)


if __name__ == '__main__':
    main(obj={}, auto_envvar_prefix='AWS')
