import pytest

from dmaws.stacks import Stack
from dmaws.stacks import BuiltStack


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
