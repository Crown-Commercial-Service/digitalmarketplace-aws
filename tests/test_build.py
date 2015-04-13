import mock
import pytest

from dmaws.build import REPOS_PATH
from dmaws.build import run_git_cmd
from dmaws.build import get_application_name_from_url
from dmaws.build import clone_or_update
from dmaws.build import push_tag
from dmaws.build import get_other_tags
from dmaws.build import get_release_name_for_tag, get_release_name_for_repo
from dmaws.build import create_archive, create_git_archive
from dmaws.build import add_directory_to_archive


class TestRunGitCmd(object):
    def test_no_args(self, run_cmd):
        run_git_cmd([], None)
        run_cmd.assert_called_with(['git'], cwd=None, stdout=-1)

    def test_args_are_appended(self, run_cmd):
        run_git_cmd(['status'], None)
        run_cmd.assert_called_with(['git', 'status'], cwd=None, stdout=-1)

    def test_cwd_is_passed_to_run_cmd(self, run_cmd):
        run_git_cmd(['status'], '/')
        run_cmd.assert_called_with(['git', 'status'], cwd='/', stdout=-1)

    def test_stdout_is_passed_to_run_cmd(self, run_cmd):
        run_git_cmd(['status'], '/', stdout=1)
        run_cmd.assert_called_with(['git', 'status'], cwd='/', stdout=1)


class TestGetApplicationName(object):
    def test_ssh_pattern(self):
        assert get_application_name_from_url(
            'git@github.com:alphagov/digitalmarketplace-aws.git'
        ) == 'aws'

    def test_https_pattern(self):
        assert get_application_name_from_url(
            'https://github.com/alphagov/digitalmarketplace-aws.git'
        ) == 'aws'


class TestCloneOrUpdate(object):
    example_repo = 'git@github.com:alphagov/digitalmarketplace-aws.git'

    def test_no_folder(self, run_cmd, mkdir, path_exists):
        path_exists.return_value = False
        clone_or_update(self.example_repo)

        mkdir.assert_called_with(REPOS_PATH)

    def test_clone(self, run_cmd):
        clone_or_update(self.example_repo)

        run_cmd.assert_has_calls([
            mock.call(['git', 'clone', self.example_repo],
                      cwd='.repos', stdout=-1),
        ])

    def test_update(self, run_cmd, path_exists):
        path_exists.return_value = True
        clone_or_update(self.example_repo)

        run_cmd.assert_has_calls([
            mock.call(['git', 'reset', '--hard', 'HEAD'],
                      cwd='.repos/digitalmarketplace-aws', stdout=-1),
            mock.call(['git', 'fetch'],
                      cwd='.repos/digitalmarketplace-aws', stdout=-1),
        ], any_order=True)


class TestPushTag(object):
    def test_new_tag(self, run_cmd):
        push_tag('repo', 'new-tag')
        run_cmd.assert_has_calls([
            mock.call(['git', 'tag', '-a', 'new-tag', '-m', 'new-tag'],
                      cwd='repo', stdout=-1),
            mock.call(['git', 'push', 'origin', 'new-tag'],
                      cwd='repo', stdout=-1),
        ])

    def test_tag_with_message(self, run_cmd):
        push_tag('repo', 'new-tag', 'New tag')
        run_cmd.assert_has_calls([
            mock.call(['git', 'tag', '-a', 'new-tag', '-m', 'New tag'],
                      cwd='repo', stdout=-1),
        ])

    def test_replace_tag(self, run_cmd):
        push_tag('repo', 'new-tag', force=True)
        run_cmd.assert_has_calls([
            mock.call(['git', 'push', 'origin', 'new-tag', '-f'],
                      cwd='repo', stdout=-1),
        ])

    def test_tag_ref(self, run_cmd):
        push_tag('repo', 'new', ref='master')
        run_cmd.assert_has_calls([
            mock.call(['git', 'tag', '-a', 'new', '-m', 'new', 'master'],
                      cwd='repo', stdout=-1),
        ])


class TestGitReleaseNameTags(object):
    def test_get_other_tags(self, run_cmd):
        run_cmd.return_value = '  tag\nnew-tag\nother_tag\n  '

        assert get_other_tags('.', 'tag') == ['new-tag', 'other_tag']

    def test_release_name_for_tag(self, run_cmd):
        run_cmd.return_value = 'tag\ntag\nrelease-not\nrelease-1\nrelease-'

        assert get_release_name_for_tag('.', 'tag') == 'release-1'

    def test_release_name_for_repo(self, run_cmd):
        run_cmd.return_value = 'fff Merge pull request #100 from'

        assert get_release_name_for_repo('.') == 'release-100'

    def test_release_name_for_repo_non_pr_commit(self, run_cmd):
        run_cmd.return_value = 'fff Revert "Merge pull request #100 from"'

        with pytest.raises(ValueError):
            get_release_name_for_repo('.')


class TestArchiveCreation(object):
    def test_git_archive(self):
        create_git_archive('./')

    def test_add_directory_to_archive(self):
        add_directory_to_archive('does-not', 'exist', '/dev/null')

    def test_create_archive(self):
        assert create_archive('does-not-exist')[2] == '/tmp/tempfile'

    def test_create_archive_patched(self, git_info):
        assert create_archive('does-not-exist') == (
            'master', 'dd93edd2cf6ade0620bb0d1e87796bb264634878',
            '/tmp/tempfile'
        )
