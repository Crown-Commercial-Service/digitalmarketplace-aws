import mock

from dmaws.context import Context


class TestContext(object):
    def test_empty_context(self):
        ctx = Context()

        assert ctx.stage is None
        assert ctx.environment is None

    @mock.patch('dmaws.context.read_yaml_file')
    def test_new_context(self, read_yaml_file, path_exists):
        ctx = Context()
        ctx.stage = 'stage'
        ctx.environment = 'environment'
        read_yaml_file.return_value = {}

        ctx2 = ctx.new_context('stage2', 'environment2', [])

        assert ctx2.stage == 'stage2'
        assert ctx2.environment == 'environment2'
        assert read_yaml_file.call_args_list == [
            mock.call('vars/common.yml'),
            mock.call('vars/stage2.yml'),
            mock.call('vars/user.yml')
        ]

    @mock.patch('dmaws.context.read_yaml_file')
    def test_new_context_with_vars_file(self, read_yaml_file, path_exists):
        ctx = Context()
        ctx.stage = 'stage'
        ctx.environment = 'environment'
        read_yaml_file.return_value = {}

        ctx2 = ctx.new_context('stage2', 'environment2', ['test.yml'])

        assert ctx2.stage == 'stage2'
        assert ctx2.environment == 'environment2'
        assert read_yaml_file.call_args_list == [
            mock.call('vars/common.yml'),
            mock.call('vars/stage2.yml'),
            mock.call('vars/user.yml'),
            mock.call('test.yml'),
        ]

    def test_add_apps(self):
        ctx = Context()

        ctx.add_apps(['api', 'aws'])
        assert ctx.apps == ['api', 'aws']

    def test_add_apps_string(self):
        ctx = Context()

        ctx.add_apps('api')
        assert ctx.apps == ['api']

    def test_add_apps_dash_to_underscore(self):
        ctx = Context()

        ctx.add_apps(['api', 'search-api'])
        assert ctx.apps == ['api', 'search_api']

    def test_add_variables(self):
        ctx = Context()

        ctx.add_variables({'a': 1})
        ctx.add_variables({'b': 2})
        ctx.add_variables({'a': 2})

        assert ctx.variables == {'a': 2, 'b': 2}

    def test_add_dotted_variable(self):
        ctx = Context()

        ctx.add_dotted_variable('a.b.c', 1)

        assert ctx.variables == {'a': {'b': {'c': 1}}}

    @mock.patch('dmaws.context.read_yaml_file')
    def test_get_variables_files(self, read_yaml_file):
        ctx = Context()

        assert ctx.get_variables_files(False, []) == []

    @mock.patch('dmaws.context.read_yaml_file')
    def test_get_variables_files_with_vars_files(self, read_yaml_file):
        ctx = Context()

        assert ctx.get_variables_files(False, ['foo.yml']) == ['foo.yml']

    @mock.patch('dmaws.context.read_yaml_file')
    def test_get_variables_files_with_default_files(self, read_yaml_file, path_exists):
        ctx = Context()
        ctx.stage = 'stage'
        path_exists.return_value = False

        assert ctx.get_variables_files(True, []) == [
            'vars/common.yml',
            'vars/stage.yml',
        ]

    @mock.patch('dmaws.context.read_yaml_file')
    def test_get_variables_files_with_default_files_and_vars(self, read_yaml_file, path_exists):
        ctx = Context()
        ctx.stage = 'stage'
        path_exists.return_value = False

        assert ctx.get_variables_files(True, ['test.yml']) == [
            'vars/common.yml',
            'vars/stage.yml',
            'test.yml',
        ]

    @mock.patch('dmaws.context.read_yaml_file')
    def test_get_variables_files_with_user_file(self, read_yaml_file, path_exists):
        ctx = Context()
        ctx.stage = 'stage'
        path_exists.return_value = True

        assert ctx.get_variables_files(True, []) == [
            'vars/common.yml',
            'vars/stage.yml',
            'vars/user.yml',
        ]
