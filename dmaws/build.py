import os
import re
import subprocess
import tempfile
import zipfile

import requests

from .utils import run_cmd

SSH_REPO_PATTERN = re.compile('git@[^:]*:[^/]+/(.*)\.git')
HTTPS_REPO_PATTERN = re.compile('https://[^/]+/[^/]+/(.*)/(?:.git)?')

RELEASE_TAG_PATTERN = re.compile(r'^release-\d+$')
MERGE_COMMIT_PATTERN = re.compile(r'[a-f0-9]+ Merge pull request #(\d+) from')

REPOS_PATH = '.repos'


def run_git_cmd(args, cwd, stdout=None):
    return run_cmd(
        ['git'] + args,
        cwd=cwd,
        stdout=stdout or subprocess.PIPE
    )


def clone_or_update(repo_url):
    app_name = get_application_name_from_url(repo_url)
    repository_path = os.path.join(REPOS_PATH,
                                   'digitalmarketplace-{}'.format(app_name))
    if not os.path.exists(REPOS_PATH):
        os.mkdir(REPOS_PATH)
    if not os.path.exists(repository_path):
        run_git_cmd(['clone', repo_url], REPOS_PATH)
    else:
        run_git_cmd(['reset', '--hard', 'HEAD'], repository_path)
        run_git_cmd(['checkout', 'master'], repository_path)
        run_git_cmd(['clean', '-fdx'], repository_path)
        run_git_cmd(['fetch'], repository_path)
        run_git_cmd(['reset', '--hard', 'origin/master'], repository_path)

    return repository_path


def get_application_name_from_url(repo_url):
    match = SSH_REPO_PATTERN.match(repo_url)
    if not match:
        match = HTTPS_REPO_PATTERN.match(repo_url)
    name = match.group(1)
    if 'digitalmarketplace-' not in name:
        raise ValueError('Application name format not recognized')
    return name.replace('digitalmarketplace-', '')


def get_application_name(cwd):
    return get_application_name_from_url(get_repo_url(cwd))


def get_repo_url(cwd):
    return run_git_cmd(['config', 'remote.origin.url'], cwd).strip()


def get_current_sha(cwd):
    return run_git_cmd(['rev-parse', 'HEAD'], cwd).strip()


def get_current_ref(cwd):
    return run_git_cmd(['rev-parse', '--abbrev-ref', 'HEAD'], cwd).strip()


def tag_exists(cwd, tag_name):
    found_tag_name = run_git_cmd(['tag', '-l', tag_name],
                                 cwd).strip()
    return found_tag_name == tag_name


def push_tag(cwd, tag_name, tag_message=None):
    if tag_message is None:
        tag_message = tag_name

    run_git_cmd(['tag', '-a', tag_name, '-m', tag_message],
                cwd).strip()
    run_git_cmd(['push', 'origin', tag_name],
                cwd).strip()


def push_deployed_to_tag(cwd, stage):
    deployed_to_tag = 'deployed-to-{}'.format(stage)
    previous_release = get_release_name_for_tag(cwd, deployed_to_tag)
    push_tag(cwd, 'deployed-to-{}'.format(stage))

    return previous_release


def get_other_tags(cwd, tag):
    """Return other tags pointing to the same commit"""
    git_cmd = ['tag', '--points-at', '{}^{{}}'.format(tag)]
    result = run_git_cmd(git_cmd, cwd).strip().split('\n')
    return [t for t in result if t is not None and t != tag]


def get_release_name_for_tag(cwd, tag):
    """Return release tag pointing to the same commit"""
    tags = get_other_tags(cwd, tag)
    tags = filter(RELEASE_TAG_PATTERN.match, tags)

    if len(tags) == 1:
        return tags[0]
    elif len(tags) > 1:
        raise ValueError(
            "More than one release tag pointing to the same commit.")


def get_release_name_for_repo(cwd):
    """Return release name generated from most recent PR merge commit"""
    result = run_git_cmd(['log', '-1', '--pretty=oneline'], cwd)
    match = MERGE_COMMIT_PATTERN.match(result)
    if not match:
        raise ValueError("Last commit was not a merge commit.")

    return 'release-{}'.format(match.group(1))


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


def set_version_label_on_archive(archive_path, version_label):
    with zipfile.ZipFile(archive_path, 'a') as archive:
        archive.writestr('version_label', "{}\n".format(version_label))


def create_archive(cwd):
    ref, sha, archive_path = create_git_archive(cwd)
    try:
        run_project_build_script(cwd)
        add_build_artefacts_to_archive(cwd, archive_path)
    except OSError:
        pass

    return ref, sha, archive_path


def notify_slack(stage, app_name, version_label,
                 previous_version_label):
    slack_url = os.environ.get("SLACK_URL")
    message_tpl = "Released {} of {} to {} (previously {})"
    message = message_tpl.format(
        version_label, app_name, stage, previous_version_label)
    if slack_url:
        requests.post(slack_url, data={
            "username": "deploy",
            "icon_emoji": ":shipit:",
            "text": message,
        })
