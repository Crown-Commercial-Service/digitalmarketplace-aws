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
@click.option('--key', help='AWS KeyPair name', required=True)
@click.option('--stage', help='Deployment stage',
              type=click.Choice(STAGES), required=True)
@click.option('--environment', help='Envrionment name', required=True)
@click.option('--db-password', help='RDS Database password')
@click.option('--tags', '-t', multiple=True)
@click.pass_context
def main(ctx, key, stage, environment, db_password, tags):
    ctx.obj['variables'] = {
        'key_name': key,
        'stage_name': stage,
        'environment_name': environment,
    }

    if db_password:
        ctx.obj['variables'].update({
            'dmapi_db_password': db_password,
        })

    ctx.obj['options'] = [
        '--private-key=~/.ssh/{}'.format(key),
    ]

    ctx.obj['tags'] = tags


@main.command()
@click.pass_context
def setup(ctx):
    """Create AWS environment and launch instances"""
    run_playbook('setup', 'hosts', **ctx.obj)


@main.command()
@click.pass_context
def provision(ctx):
    """Provision EC2 instances"""
    run_playbook('provision', 'ec2.py', **ctx.obj)


@main.command()
@click.pass_context
@click.option('--with-base/--skip-base', default=False)
def teardown(ctx, with_base):
    """Destroy AWS environment and terminate running instances"""

    kwargs = ctx.obj.copy()
    if not with_base:
        kwargs['options'] = ctx.obj['options'] + ['--skip-tags=base']

    run_playbook('teardown', 'hosts', **kwargs)


if __name__ == '__main__':
    main(obj={}, auto_envvar_prefix='AWS')
