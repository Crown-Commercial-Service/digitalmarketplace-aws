import pytest
import mock

from .helpers import set_boto_response

from boto.s3.bucket import Bucket as S3Bucket
from boto.s3.connection import S3Connection
from boto.beanstalk.layer1 import Layer1 as BeanstalkConnection
from dmaws.utils import run_cmd as run_cmd_orig


@pytest.fixture(autouse=True)
def beanstalk_conn(request):
    beanstalk_mock = mock.Mock(spec=BeanstalkConnection)
    beanstalk_patch = mock.patch('boto.beanstalk.connect_to_region',
                                 return_value=beanstalk_mock)

    beanstalk_patch.start()
    request.addfinalizer(beanstalk_patch.stop)

    set_boto_response(beanstalk_mock, 'create_storage_location', {
        'S3Bucket': 'test-bucket'
    })

    set_boto_response(beanstalk_mock, 'update_environment', metadata={
        'RequestId': 'test-request-1'
    })

    set_boto_response(beanstalk_mock, 'describe_events', {
        'Events': [
            {'EventDate': 1427976389, 'Severity': 'UPDATE', 'Message': 'msg'}
        ]
    })

    set_boto_response(beanstalk_mock, 'describe_environments', {
        'Environments': [
            {
                'Status': 'Ready',
                'CNAME': 'test.domain.local'
            }
        ]
    })

    set_boto_response(beanstalk_mock, 'describe_application_versions', {
        'ApplicationVersions': ['test-version']
    })

    return beanstalk_mock


@pytest.fixture(autouse=True)
def s3_conn(request, s3_bucket):
    s3_mock = mock.Mock(S3Connection)
    s3_patch = mock.patch('boto.s3.connect_to_region', return_value=s3_mock)
    s3_patch.start()
    request.addfinalizer(s3_patch.stop)

    s3_mock.get_bucket.return_value = s3_bucket

    return s3_mock


@pytest.fixture()
def s3_bucket():
    return mock.Mock(spec=S3Bucket)


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
    temp.return_value = -1, '/tmp/tempfile'

    return temp
