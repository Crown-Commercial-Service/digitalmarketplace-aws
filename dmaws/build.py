import os
import re
import subprocess
import tempfile
import zipfile

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


def add_directory_to_archive(cwd, path, archive_path):
    with zipfile.ZipFile(archive_path, 'a') as archive:
        for root, dirs, files in os.walk(os.path.join(cwd, path)):
            for f in dirs + files:
                file_path = os.path.join(root, f)
                archive.write(os.path.join(root, f),
                              arcname=os.path.relpath(file_path, cwd))


def create_git_archive(cwd):
    sha = get_current_sha(cwd)
    ref = get_current_ref(cwd)
    package_file, file_path = tempfile.mkstemp()

    run_git_cmd(['archive', '--format=zip', 'HEAD'], cwd, stdout=package_file)

    os.close(package_file)

    return ref, sha, file_path


def run_project_build_script(cwd):
    run_cmd(['./scripts/build.sh'], cwd=cwd)


def add_build_artefacts_to_archive(cwd, archive):
    add_directory_to_archive(cwd, 'app/static', archive)
    add_directory_to_archive(cwd, 'bower_components', archive)


def create_archive(cwd):
    ref, sha, archive_path = create_git_archive(cwd)
    try:
        run_project_build_script(cwd)
        add_build_artefacts_to_archive(cwd, archive_path)
    except OSError:
        pass

    return ref, sha, archive_path
