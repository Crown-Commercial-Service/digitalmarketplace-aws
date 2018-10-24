import mock
import pytest

from dmaws.utils import (
    DEFAULT_TEMPLATES_PATH,
    merge_dicts,
    safe_path_join,
    template, template_string, LazyTemplateMapping, UndefinedError,
    mkdir_p,
)


class TestSafePathJoin(object):
    def test_simple_subpath(self):
        assert safe_path_join('', 'app/static') == 'app/static'

    def test_relative_basedir_subpath(self):
        assert safe_path_join('./', 'app/static') == './app/static'

    def test_relative_basedir_relative_subpath(self):
        assert safe_path_join('./', './app/static') == '././app/static'

    def test_relative_basedir_parent_subpath(self):
        with pytest.raises(ValueError):
            safe_path_join('./', '../../app/static')

    def test_relative_basedir_root_subpath(self):
        with pytest.raises(ValueError):
            safe_path_join('./', '/app/static')

    def test_relative_basedir_root_subdir_subpath(self):
        with pytest.raises(ValueError):
            safe_path_join('./', '/../../app/static')


class TestMergeDicts(object):
    def test_simple_dicts(self):
        assert merge_dicts({"a": 1}, {"b": 2}) == {"a": 1, "b": 2}

    def test_overwriting_key(self):
        assert merge_dicts({"a": 1}, {"a": 2}) == {"a": 2}

    def test_overwriting_list_key(self):
        assert merge_dicts({"a": [1]}, {"a": [2]}) == {"a": [2]}

    def test_no_overwriting_dict_keys(self):
        with pytest.raises(ValueError):
            assert merge_dicts({"a": {"a": 1}}, {"a": 2}) == {"a": 2}

    def test_replacing_keys_with_dicts(self):
        assert merge_dicts({"a": 2}, {"a": {"a": 1}}) == {"a": {"a": 1}}

    def test_dict_keys_are_merged(self):
        assert(
            merge_dicts({"a": {"a": 1}}, {"a": {"b": 2}})
            == {"a": {"a": 1, "b": 2}}
        )

    def test_nested_dicts(self):
        assert(
            merge_dicts({"a": {"a": 1, "b": 1}, "b": {"a": 1, "b": 1}},
                        {"a": {"a": 2}, "b": {"b": 2}})
            == {"a": {"a": 2, "b": 1}, "b": {"a": 1, "b": 2}}
        )


class TestTemplateString(object):
    def test_simple_string(self):
        assert template_string("string", {}) == "string"

    def test_template_string(self):
        assert template_string("{{ var }} string", {"var": "a"}) == "a string"

    def test_template_dot_accessor(self):
        assert(
            template_string("{{ var.name }} string", {"var": {"name": "a"}})
            == "a string"
        )

    def test_missing_variable(self):
        with pytest.raises(UndefinedError):
            assert template_string("{{ var }} string", {}) == "a string"

    def test_template_loader(self):
        assert template_string('{% extends "base.j2" %}', {},
                               templates_path="tests/templates/")

    @mock.patch('dmaws.utils.jinja2.FileSystemLoader')
    def test_template_loader_default_path(self, jinja_loader):
        template_string('string', {})

        jinja_loader.assert_called_with(DEFAULT_TEMPLATES_PATH)


class TestTemplate(object):
    def test_template_string(self):
        assert template("{{ var }} string", {"var": "a"}) == "a string"

    def test_template_list(self):
        assert(
            template(["{{ avar }}", "{{ bvar }}"], {"avar": "a", "bvar": "b"})
            == ["a", "b"]
        )

    def test_template_dict(self):
        assert(
            template({"a": "{{ avar }}", "b": "{{ bvar }}"},
                     {"avar": "a", "bvar": "b"})
            == {"a": "a", "b": "b"}
        )

    def test_template_nested_list(self):
        assert(
            template([["{{ avar }}"], "{{ bvar }}"],
                     {"avar": "a", "bvar": "b"})
            == [["a"], "b"]
        )

    def test_template_nested_dict(self):
        assert(
            template({"a": {"a": "{{ avar }}"}, "b": "{{ bvar }}"},
                     {"avar": "a", "bvar": "b"})
            == {"a": {"a": "a"}, "b": "b"}
        )

    @mock.patch('dmaws.utils.jinja2.FileSystemLoader')
    def test_template_loader_default_path(self, jinja_loader):
        template('string', {})

        jinja_loader.assert_called_with(DEFAULT_TEMPLATES_PATH)


class TestLazyTemplateMapping(object):
    def test_not_templated_on_init(self):
        assert LazyTemplateMapping({"key": "{{ var }}"}, {})

    def test_single_key(self):
        mapping = LazyTemplateMapping({"key": "test", "err": "{{ var }}"},
                                      {"var": "a"})
        assert mapping["key"] == "test"

    def test_kwargs_shadow_variables(self):
        mapping = LazyTemplateMapping({"a": "{{ var }}", "b": "{{ var }}"},
                                      {"var": "var"}, var="kwarg")
        assert mapping["a"] == "kwarg"

    def test_missing_key_error(self):
        mapping = LazyTemplateMapping({"key": "{{ var }}"}, {})

        with pytest.raises(KeyError):
            mapping['missing']

    def test_keys(self):
        mapping = LazyTemplateMapping({"a": "{{ var }}", "b": "{{ var }}"}, {})
        assert set(mapping.keys()) == set(["a", "b"])

    def test_items(self):
        mapping = LazyTemplateMapping({"a": "{{ var }}a", "b": "{{ var }}b"},
                                      {"var": "a"})
        assert set(mapping.items()) == set([("a", "aa"), ("b", "ab")])


class TestMkdirP(object):

    def test_directories_created(self, makedirs):
        mkdir_p('path/to/create')
        makedirs.assert_called_with('path/to/create')

    @pytest.mark.parametrize("path_exists", [
        True, False
    ])
    def test_directories_created_if_they_exist(self, makedirs, isdir, path_exists):
        makedirs.side_effect = OSError()
        isdir.return_value = path_exists

        if path_exists:
            mkdir_p('path/to/create')
            makedirs.assert_called_with('path/to/create')

        else:
            with pytest.raises(OSError):
                mkdir_p('path/to/create')
