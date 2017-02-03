import click
import os
import yaml
import subprocess

from ..cli import cli_command
from ..utils import load_file, template_string, run_piped_cmds

@cli_command('paas-manifest', max_apps=1)
@click.option('--template', '-t', default='paas/manifest.j2',
              type=click.Path(exists=True),
              help="Manifest Jinja2 template file")
@click.option('--credentials-repo', '-c', envvar='DM_CREDENTIALS_REPO',
              type=click.Path(exists=True),
              help="Path to the digitalmarketplace-credentials repository")
@click.option('--out-file', '-o',
              help="Output file, if empty the template content is printed to the stdout")
def paas_manifest(ctx, template, credentials_repo, out_file):
    """Generate a PaaS manifest file from a Jinja2 template"""
    app = ctx.apps[0]

    if not app in ctx.variables:
        raise ValueError('Application configuration not found')

    ctx.add_variables(get_secret_vars(credentials_repo, 'vars/common/.yml'))
    ctx.add_variables(get_secret_vars(credentials_repo, 'vars/{}.yaml'.format(ctx.environment)))

    templace_content = load_file(template)
    variables = {
        'environment': ctx.environment,
        'app': app
    }
    variables.update(ctx.variables[app])

    manifest_content = template_string(templace_content, variables)

    if out_file is not None:
        with open(out_file, 'w') as f:
            f.write(manifest_content)
        os.chmod(out_file, 0o600)
    else:
        print(manifest_content)

def get_secret_vars(credentials_repo, filename):
    sops_wrapper = '{}/sops-wrapper'.format(credentials_repo)
    sops_file = '{}/{}'.format(credentials_repo, filename)
    if os.path.exists(sops_file):
        secrets_yaml = run_piped_cmds(cmds=[[sops_wrapper, '-d', sops_file]], stdout=subprocess.PIPE)
        return yaml.load(secrets_yaml)

    return {}
