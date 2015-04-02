import mock
import pytest

from dmaws.utils import run_cmd, CalledProcessError


class TestRunCmd(object):
    def test_run_cmd(self, subprocess):
        run_cmd(["ls"])

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={}, stdout=None, stderr=mock.ANY, cwd=None
        )

    def test_env_is_using_os_environ(self, os_environ, subprocess):
        os_environ.update({"OS": "1"})
        run_cmd(["ls"])

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={"OS": "1"}, stdout=None, stderr=mock.ANY, cwd=None
        )

    def test_env_is_added_to_os_env(self, os_environ, subprocess):
        os_environ.update({"OS": "2"})
        run_cmd(["ls"], env={"ENV": "2"})

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={"OS": "2", "ENV": "2"}, stdout=None, stderr=mock.ANY, cwd=None
        )

    def test_cwd_is_passed_to_popen(self, subprocess):
        run_cmd(["ls"], cwd="/")

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={}, stdout=None, stderr=mock.ANY, cwd="/"
        )

    def test_stdout_is_passed_to_popen(self, subprocess):
        run_cmd(["ls"], stdout=1)

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={}, stdout=1, stderr=mock.ANY, cwd=None
        )

    def test_exception_on_non_zero_return_code(self, subprocess):
        subprocess.Popen.return_value.returncode = 128

        with pytest.raises(CalledProcessError):
            run_cmd(["ls"])

    def test_ignore_errors_doesnt_raise_an_exception(self, subprocess):
        subprocess.Popen.return_value.returncode = 128

        run_cmd(["ls"], ignore_errors=True)

    def test_logging(self, subprocess):
        subprocess.Popen.return_value.returncode = 7
        logger = mock.Mock()

        run_cmd(["ls"], logger=logger, ignore_errors=True)

        logger.assert_has_calls([
            mock.call(mock.ANY, "ls"),
            mock.call(mock.ANY, "ls", 7)
        ])
