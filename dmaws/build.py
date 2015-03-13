import os
import re
import subprocess
import tempfile

from .utils import run_cmd

SSH_REPO_PATTERN = re.compile('git@[^:]*:[^/]+/(.*)\.git')
HTTPS_REPO_PATTERN = re.compile('https://[^/]+/[^/]+/(.*)/(?:.git)?')


def run_git_cmd(args, cwd, stdout=None):
    return run_cmd(
        ['git'] + args,
        cwd=cwd,
        stdout=stdout or subprocess.PIPE
    )


def get_application_name(cwd):
    repo_url = get_repo_url(cwd)
    match = SSH_REPO_PATTERN.match(repo_url)
    if not match:
        match = HTTPS_REPO_PATTERN.match(repo_url)
    name = match.group(1)
    if 'digitalmarketplace-' not in name:
        raise ValueError('Application name format not recognized')
    return name.replace('digitalmarketplace-', '')


def get_repo_url(cwd):
    return run_git_cmd(['config', 'remote.origin.url'], cwd).strip()


def get_current_sha(cwd):
    return run_git_cmd(['rev-parse', 'HEAD'], cwd).strip()


def get_current_ref(cwd):
    return run_git_cmd(['rev-parse', '--abbrev-ref', 'HEAD'], cwd).strip()


def create_archive(cwd):
    sha = get_current_sha(cwd)
    ref = get_current_ref(cwd)
    package_file, file_path = tempfile.mkstemp()

    run_git_cmd(['archive', '--format=zip', 'HEAD'], cwd, stdout=package_file)

    os.close(package_file)

    return ref, sha, file_path
