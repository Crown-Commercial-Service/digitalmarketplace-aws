import datetime

import pytest
import mock

from .helpers import set_boto_response, set_cloudformation_stack
from .helpers import CFOutput, CFEvent, CFResource

from boto.s3.bucket import Bucket as S3Bucket
from boto.s3.connection import S3Connection
from boto.beanstalk.layer1 import Layer1 as BeanstalkConnection
from boto.cloudformation.connection import CloudFormationConnection

from dmaws.utils import run_cmd as run_cmd_orig
from dmaws.build import get_repo_url, get_current_sha, get_current_ref


@pytest.fixture()
def git_info(request):
    patches = [
        mock.patch(
            'dmaws.build.get_repo_url', wraps=get_repo_url,
            return_value='git@github.com:alphagov/digitalmarketplace-aws.git'),
        mock.patch(
            'dmaws.build.get_current_sha', wraps=get_current_sha,
            return_value='dd93edd2cf6ade0620bb0d1e87796bb264634878'),
        mock.patch(
            'dmaws.build.get_current_ref', wraps=get_current_ref,
            return_value='master'),
    ]

    for patch in patches:
        patch.start()
        request.addfinalizer(patch.stop)


@pytest.fixture(autouse=True)
def cloudformation_conn(request):
    cloudformation_mock = mock.Mock(spec=CloudFormationConnection)
    cloudformation_patch = mock.patch('boto.cloudformation.connect_to_region',
                                      return_value=cloudformation_mock)

    cloudformation_patch.start()
    request.addfinalizer(cloudformation_patch.stop)

    set_cloudformation_stack(cloudformation_mock, 'aws', 'CREATE_COMPLETE')

    return cloudformation_mock


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
                'VersionLabel': 'release-0',
                'CNAME': 'test.domain.local'
            }
        ]
    })

    set_boto_response(beanstalk_mock, 'describe_application_versions', {
        'ApplicationVersions': [
            {
                'ApplicationName': 'test-env',
                'VersionLabel': 'test-version'
            }
        ]
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
    bucket = mock.Mock(spec=S3Bucket)
    bucket.get_key.return_value = False

    return bucket


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
