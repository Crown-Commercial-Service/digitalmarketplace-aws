import pytest
import mock


@pytest.fixture()
def os_environ(request):
    env_patch = mock.patch('os.environ', {})
    request.addfinalizer(env_patch.stop)

    return env_patch.start()


@pytest.fixture(autouse=True)
def subprocess(request, os_environ):
    patch = mock.patch('dmaws.utils.subprocess')
    request.addfinalizer(patch.stop)

    subprocess = patch.start()
    subprocess.Popen.return_value.returncode = 0

    return subprocess
