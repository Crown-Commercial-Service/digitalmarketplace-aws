import mock
import pytest

from dmaws.utils import run_cmd, CalledProcessError
from dmaws.utils import dict_from_path, merge_dicts
from dmaws.utils import DEFAULT_TEMPLATES_PATH
from dmaws.utils import template, template_string, LazyTemplateMapping


class TestRunCmd(object):
    def test_run_cmd(self, subprocess):
        run_cmd(["ls"])

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={}, stdout=None, stderr=mock.ANY, cwd=None
        )

    def test_env_is_using_os_environ(self, os_environ, subprocess):
        os_environ.update({"OS": "1"})
        run_cmd(["ls"])

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={"OS": "1"}, stdout=None, stderr=mock.ANY, cwd=None
        )

    def test_env_is_added_to_os_env(self, os_environ, subprocess):
        os_environ.update({"OS": "2"})
        run_cmd(["ls"], env={"ENV": "2"})

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={"OS": "2", "ENV": "2"}, stdout=None, stderr=mock.ANY, cwd=None
        )

    def test_cwd_is_passed_to_popen(self, subprocess):
        run_cmd(["ls"], cwd="/")

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={}, stdout=None, stderr=mock.ANY, cwd="/"
        )

    def test_stdout_is_passed_to_popen(self, subprocess):
        run_cmd(["ls"], stdout=1)

        subprocess.Popen.assert_called_once_with(
            ["ls"],
            env={}, stdout=1, stderr=mock.ANY, cwd=None
        )

    def test_exception_on_non_zero_return_code(self, subprocess):
        subprocess.Popen.return_value.returncode = 128

        with pytest.raises(CalledProcessError):
            run_cmd(["ls"])

    def test_ignore_errors_doesnt_raise_an_exception(self, subprocess):
        subprocess.Popen.return_value.returncode = 128

        run_cmd(["ls"], ignore_errors=True)

    def test_logging(self, subprocess):
        subprocess.Popen.return_value.returncode = 7
        logger = mock.Mock()

        run_cmd(["ls"], logger=logger, ignore_errors=True)

        logger.assert_has_calls([
            mock.call(mock.ANY, "ls"),
            mock.call(mock.ANY, "ls", 7)
        ])


class TestDictFromPath(object):
    def test_simple_string(self):
        assert dict_from_path("key", 1) == {"key": 1}

    def test_dotted_pair_string(self):
        assert dict_from_path("nested.key", 1) == {"nested": {"key": 1}}

    def test_digits_are_treated_as_strings(self):
        assert dict_from_path("0.key", 1) == {"0": {"key": 1}}

    def test_nested_string(self):
        assert dict_from_path("very.nested.key", 1) == {
            "very": {"nested": {"key": 1}}
        }


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
        with pytest.raises(ValueError):
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

    def test_keys(self):
        mapping = LazyTemplateMapping({"a": "{{ var }}", "b": "{{ var }}"}, {})
        assert mapping.keys() == ["a", "b"]

    def test_items(self):
        mapping = LazyTemplateMapping({"a": "{{ var }}a", "b": "{{ var }}b"},
                                      {"var": "a"})
        assert mapping.items() == [("a", "aa"), ("b", "ab")]
