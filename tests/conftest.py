import pytest
import mock

from dmaws.utils import run_cmd as run_cmd_orig


@pytest.fixture()
def run_cmd(request):
    run_cmd_wrap = mock.patch('dmaws.utils.run_cmd',
                              wraps=run_cmd_orig)
    request.addfinalizer(run_cmd_wrap.stop)

    return run_cmd_wrap.start()


@pytest.fixture(autouse=True)
def subprocess(request, os_environ):
    patch = mock.patch('dmaws.utils.subprocess')
    request.addfinalizer(patch.stop)

    subprocess = patch.start()
    subprocess.Popen.return_value.returncode = 0

    return subprocess


@pytest.fixture()
def os_environ(request):
    env_patch = mock.patch('os.environ', {})
    request.addfinalizer(env_patch.stop)

    return env_patch.start()


@pytest.fixture()
def path_exists(request):
    path_patch = mock.patch('os.path.exists')
    request.addfinalizer(path_patch.stop)

    path_exists = path_patch.start()
    path_exists.return_value = True

    return path_exists


@pytest.fixture(autouse=True)
def mkdir(request):
    mkdir_patch = mock.patch('os.mkdir')
    request.addfinalizer(mkdir_patch.stop)

    return mkdir_patch.start()


@pytest.fixture(autouse=True)
def os_close(request):
    os_close_patch = mock.patch('os.close')
    request.addfinalizer(os_close_patch.stop)

    return os_close_patch.start()


@pytest.fixture(autouse=True)
def zipfile(request):
    zipfile_patch = mock.patch('zipfile.ZipFile')
    request.addfinalizer(zipfile_patch.stop)

    return zipfile_patch.start()


@pytest.fixture(autouse=True)
def mkstemp(request):
    temp_patch = mock.patch('tempfile.mkstemp')
    request.addfinalizer(temp_patch.stop)

    temp = temp_patch.start()
    temp.return_value = -1, '/dev/null'

    return temp
