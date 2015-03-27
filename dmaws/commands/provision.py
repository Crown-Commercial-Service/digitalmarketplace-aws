import os
import json
import subprocess

from ..cli import cli_command
from ..utils import run_cmd


def run_playbook(playbook, hosts, ctx, basedir='playbooks/'):
    args = [
        'ansible-playbook',
        os.path.join(basedir, playbook + '.yml'),
        '-i',
        os.path.join(basedir, hosts),
    ]

    args.extend([
        '-e',
        json.dumps(ctx.variables),
        '-e',
        json.dumps({'stage': ctx.stage, 'environment': ctx.environment})
    ])

    ctx.log(subprocess.list2cmdline(args))

    run_cmd(args, env={
        'ANSIBLE_CONFIG': os.path.join(basedir, 'ansible.cfg')
    })


@cli_command('provision', max_apps=0)
def provision_cmd(ctx):
    """Provision EC2 instances"""
    run_playbook('provision', 'ec2', ctx)
