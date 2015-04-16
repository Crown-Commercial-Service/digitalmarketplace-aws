from dmaws.context import Context


class TestContext(object):
    def test_empty_context(self):
        ctx = Context()

        assert ctx.stage is None
        assert ctx.environment is None

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
