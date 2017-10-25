import pytest
import mock

from dmaws.utils import mkdir_p as mkdir_p_orig


@pytest.fixture()
def path_exists(request):
    path_patch = mock.patch('os.path.exists')
    request.addfinalizer(path_patch.stop)

    path_exists = path_patch.start()
    path_exists.return_value = True

    return path_exists


@pytest.fixture()
def isdir(request):
    isdir_patch = mock.patch('os.path.isdir')
    request.addfinalizer(isdir_patch.stop)

    isdir = isdir_patch.start()
    isdir.return_value = True

    return isdir


@pytest.fixture()
def makedirs(request):
    makedirs_patch = mock.patch('os.makedirs')
    request.addfinalizer(makedirs_patch.stop)

    return makedirs_patch.start()


@pytest.fixture()
def mkdir_p(request):
    mkdir_p_patch = mock.patch('dmaws.utils.mkdir_p', wraps=mkdir_p_orig)
    request.addfinalizer(mkdir_p_patch.stop)

    return mkdir_p_patch.start()


@pytest.fixture(autouse=True)
def os_close(request):
    os_close_patch = mock.patch('os.close')
    request.addfinalizer(os_close_patch.stop)

    return os_close_patch.start()


@pytest.fixture(autouse=True)
def os_remove(request):
    os_remove_patch = mock.patch('os.remove')
    request.addfinalizer(os_remove_patch.stop)

    return os_remove_patch.start()


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
    temp.return_value = -1, '/tmp/tempfile'

    return temp


@pytest.fixture(autouse=True)
def sleep(request):
    sleep_patch = mock.patch('time.sleep')
    request.addfinalizer(sleep_patch.stop)

    return sleep_patch.start()
