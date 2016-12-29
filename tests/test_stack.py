import mock
import pytest

from .helpers import set_cloudformation_stack

from dmaws.stacks import Stack
from dmaws.stacks import BuiltStack
from dmaws.stacks import StackPlan


AWS_REGION = 'fake-region'


class TestStack(object):
    def test_stack_init(self):
        stack = Stack('aws', 'aws.json')

        assert stack.name == 'aws'
        assert stack.template == 'aws.json'
        assert stack.repo_url is None
        assert stack.parameters == {}
        assert stack.dependencies == []

    def test_stack_with_parameters(self):
        stack = Stack('aws', 'aws.json', {'param': 1})

        assert stack.parameters == {'param': 1}


class TestBuiltStack(object):
    def test_built_stack_init(self):
        stack = Stack('aws', 'aws.json')
        built_stack = BuiltStack(stack, 'stage', 'env', {})

        assert built_stack.name == 'aws'
        assert built_stack.parameters.items() == []

    def test_init_from_stack_build(self):
        stack = Stack('aws', 'aws.json').build('stage', 'env', {})

        assert stack.name == 'aws'
        assert stack.parameters.items() == []

    def test_name_is_templated(self):
        stack = Stack('a-{{ stage }}-{{ environment }}', 'aws.json').build(
            'stage', 'env', {}
        )

        assert stack.name == 'a-stage-env'

    def test_name_is_templated_without_variables(self):
        with pytest.raises(ValueError):
            Stack('a-{{ var }}', 'aws.json').build(
                'stage', 'env', {'var': 'name'}
            )

    def test_parameters_are_templated(self):
        stack = Stack(
            'aws', 'aws.json', parameters={'key': '{{ var }}'}
        ).build(
            'stage', 'env', {'var': 'val'}
        )

        assert stack.parameters['key'] == 'val'

    def test_parameters_are_lazy(self):
        stack = Stack(
            'aws', 'aws.json', parameters={'key': 1, 'err': '{{ var }}'}
        ).build(
            'stage', 'env', {}
        )

        assert stack.parameters['key'] == 1

        with pytest.raises(ValueError):
            stack.parameters['err']

    def test_update_info(self):
        stack = Stack('aws', 'aws.json').build('stage', 'env', {})

        stack.update_info({'status': 'ok', 'outputs': {}, 'resources': {}})

        assert stack.status == 'ok'
        assert stack.outputs == {}
        assert stack.resources == {}

    def test_update_info_additional_attrs_are_ignored(self):
        stack = Stack('aws', 'aws.json').build('stage', 'env', {})

        stack.update_info({
            'status': 'ok', 'outputs': {}, 'resources': {}, 'failed': True
        })

        assert not hasattr(stack, 'failed')

    def test_update_info_missing_attr(self):
        stack = Stack('aws', 'aws.json').build('stage', 'env', {})

        with pytest.raises(KeyError):
            stack.update_info({})

    def test_template_body(self):
        stack = Stack('aws', 'tests/templates/aws.json').build(
            'stage', 'env', {}
        )

        assert stack.template_body == "{}\n"

    def test_template_body_with_envvars(self):
        stack = Stack(
            'aws', 'tests/templates/aws.json', parameters={
                'Environment': 'env',
                'EnvVarDmName': 'name',
            }
        ).build('stage', 'env', {})

        assert stack.template_body == "{}\nEnvVarDmName,DM_NAME\n"


class TestStackPlan(object):
    def test_init(self):
        plan = StackPlan({
            'aws': Stack('aws', 'aws.json')
        }, 'stage', 'env', {'aws_region': AWS_REGION}, ['aws'])

        assert plan.stack_context == {'aws_region': AWS_REGION, 'stacks': {}}

    @pytest.mark.parametrize('from_ctx_kwargs', [
        {},
        {'profile_name': 'stage'},
    ])
    def test_stackplan_from_ctx(self, from_ctx_kwargs):
        # stage will always be set in the context,
        # but it should only be applied if passed in explicitly
        mock_ctx = mock.Mock(
            stacks={},
            stage='stage',
            environment='environment',
            variables={'aws_region': AWS_REGION},
            apps=[],
            log=None
        )

        plan = StackPlan.from_ctx(mock_ctx, **from_ctx_kwargs)

        assert plan._stacks == {}
        assert plan.stage == 'stage'
        assert plan.environment == 'environment'
        assert plan.stack_context == {'aws_region': AWS_REGION, 'stacks': {}}
        assert plan.apps == []
        assert plan.log() is None
        assert plan.profile_name is None if not from_ctx_kwargs else from_ctx_kwargs['profile_name']

    def test_stacks_variable_is_reserved(self):
        with pytest.raises(ValueError):
            StackPlan({
                'aws': Stack('aws', 'aws.json')
            }, 'stage', 'env', {'aws_region': AWS_REGION, 'stacks': []}, [])

    def test_apps_list_is_flattened(self):
        plan = StackPlan(
            {
                'all': ['aws', 'api', 'api_list'],
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['all', 'aws']
        )

        assert plan.apps == ['api', 'aws']

    def test_stacks_list(self):
        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api_list', 'aws']
        )

        assert plan.stacks() == [('api', mock.ANY), ('aws', mock.ANY)]

    def test_stacks_list_from_apps(self):
        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api', 'aws']
        )

        assert plan.stacks(['api_list']) == [('api', mock.ANY)]

    def test_stacks_dependencies_list(self):
        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api_list', 'aws']
        )

        assert plan.stacks(with_dependencies=True) == [
            ('aws', mock.ANY), ('db', mock.ANY), ('api', mock.ANY)
        ]

    def test_dependant_stacks_list(self):
        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['db', 'aws']
        )

        assert plan.dependant_stacks() == [
            ('api', mock.ANY), ('aws', mock.ANY), ('db', mock.ANY)
        ]

    def test_build_stack(self):
        plan = StackPlan({
            'aws': Stack('aws', 'aws.json')
        }, 'stage', 'env', {'aws_region': AWS_REGION}, ['aws'])

        assert plan.build_stack(plan.stacks()[0][1]).name == 'aws'

    def test_get_value(self):
        plan = StackPlan({
            'aws': Stack('aws', 'aws.json')
        }, 'stage', 'env', {'aws_region': AWS_REGION}, ['aws'])

        assert plan.get_value('aws_region') == AWS_REGION

    def test_get_nested_value(self):
        plan = StackPlan({'aws': Stack('aws', 'aws.json')},
                         'stage', 'env',
                         {'aws_region': AWS_REGION, 'aws': {'stacks': 2}},
                         ['aws'])

        assert plan.get_value('aws.stacks') == 2

    def test_stack_info(self, cloudformation_conn):
        plan = StackPlan(
            {
                'aws': Stack('aws', 'aws.json'),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['aws']
        )

        assert plan.info()['aws'].status == 'CREATE_COMPLETE'

    def test_stack_info_with_dependencies(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'CREATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'UPDATE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            []
        )

        info = plan.info(['api'])

        assert info['api'].status == 'CREATE_COMPLETE'
        assert info['db'].status == 'UPDATE_COMPLETE'

    def test_stack_info_from_apps(self):
        plan = StackPlan(
            {
                'aws': Stack('aws', 'aws.json'),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            []
        )

        assert plan.info(['aws'])['aws'].status == 'CREATE_COMPLETE'

    def test_stack_info_missing(self):
        plan = StackPlan(
            {
                'aws': Stack('aws', 'aws.json'),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            []
        )

        assert not plan.info(['db'])['db'].status

    def test_stack_info_without_aws(self):
        plan = StackPlan(
            {
                'aws': Stack('aws', 'aws.json'),
                'db': Stack('db', 'db.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            []
        )

        info = plan.info(['aws'], with_aws=False)

        assert info['aws'].name == 'aws'
        assert not info['aws'].status

    def test_stack_create(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'CREATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'UPDATE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['db']
        )

        assert plan.create()

        cloudformation_conn.create_stack.assert_has_calls([
            mock.call(u'db', template_body=mock.ANY,
                      parameters=[], capabilities=mock.ANY),
        ])

    def test_stack_create_failed(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'CREATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'UPDATE_FAILED')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['db']
        )

        assert not plan.create()

        cloudformation_conn.create_stack.assert_has_calls([
            mock.call(u'db', template_body=mock.ANY,
                      parameters=[], capabilities=mock.ANY),
        ])

    def test_stack_create_dependencies(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'UPDATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'UPDATE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'tests/templates/aws.json',
                             dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api']
        )

        assert plan.create()
        cloudformation_conn.create_stack.assert_has_calls([
            mock.call(u'db', template_body=mock.ANY,
                      parameters=[], capabilities=mock.ANY),
            mock.call(u'api', template_body=mock.ANY,
                      parameters=[], capabilities=mock.ANY),
        ])

    def test_stack_create_without_dependencies(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'UPDATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'CREATE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'tests/templates/aws.json',
                             dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api']
        )

        assert plan.create(create_dependencies=False)
        cloudformation_conn.create_stack.assert_has_calls([
            mock.call(u'api', template_body=mock.ANY,
                      parameters=[], capabilities=mock.ANY),
        ])

    def test_stack_create_with_missing_dependencies(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'UPDATE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'tests/templates/aws.json',
                             dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api']
        )

        assert not plan.create(create_dependencies=False)
        assert not cloudformation_conn.called

    def test_stack_delete(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'DELETE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'DELETE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api']
        )

        assert plan.delete()

        cloudformation_conn.delete_stack.assert_has_calls([
            mock.call(u'api')
        ])

    def test_stack_delete_failed(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'DELETE_FAILED')
        set_cloudformation_stack(cloudformation_conn, 'db', 'DELETE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['api']
        )

        assert not plan.delete()

        cloudformation_conn.delete_stack.assert_has_calls([
            mock.call(u'api')
        ])

    def test_stack_delete_with_dependant_stack(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'CREATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'UPDATE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['db']
        )

        assert not plan.delete()
        assert not cloudformation_conn.delete_stack.called

    def test_stack_delete_ignore_dependencies(self, cloudformation_conn):
        set_cloudformation_stack(cloudformation_conn, 'api', 'CREATE_COMPLETE')
        set_cloudformation_stack(cloudformation_conn, 'db', 'DELETE_COMPLETE')

        plan = StackPlan(
            {
                'api_list': ['api'],
                'aws': Stack('aws', 'aws.json'),
                'api': Stack('api', 'api.json', dependencies=['db']),
                'db': Stack('db', 'tests/templates/aws.json'),
            }, 'stage', 'env',
            {'aws_region': AWS_REGION},
            ['db']
        )

        assert plan.delete(True)

        cloudformation_conn.delete_stack.assert_has_calls([
            mock.call(u'db')])

    def test_get_deploy(self):
        plan = StackPlan({
            'aws': Stack('aws', 'aws.json',
                         parameters={
                             'ApplicationName': 'app',
                             'EnvironmentName': 'app-env',
                         })
        }, 'stage', 'env', {'aws_region': AWS_REGION}, ['aws'])

        assert plan.get_deploy().eb_application == 'app'

    def test_get_deploy_multiple_apps(self):
        plan = StackPlan({
            'aws': Stack('aws', 'aws.json'),
            'api': Stack('api', 'api.json'),
        }, 'stage', 'env', {'aws_region': AWS_REGION}, ['aws', 'api'])

        with pytest.raises(ValueError):
            plan.get_deploy()
