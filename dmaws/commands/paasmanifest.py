import click
import os

from ..cli import cli_command
from ..utils import load_file, template_string


@cli_command('paas-manifest', max_apps=1)
@click.option('--template', '-t', default='paas/manifest.j2',
              type=click.Path(exists=True),
              help="Manifest Jinja2 template file")
@click.option('--out-file', '-o',
              help="Output file, if empty the template content is printed to the stdout")
def paas_manifest(ctx, template, out_file):
    """Generate a PaaS manifest file from a Jinja2 template"""
    app = ctx.apps[0]

    if app not in ctx.variables:
        raise ValueError('Application configuration not found')

    templace_content = load_file(template)
    variables = {
        'environment': ctx.environment,
        'app': app.replace('_', '-')
    }
    variables.update(ctx.variables[app])

    manifest_content = template_string(templace_content, variables)

    if out_file is not None:
        with open(out_file, 'w') as f:
            f.write(manifest_content)
        os.chmod(out_file, 0o600)
    else:
        print(manifest_content)
