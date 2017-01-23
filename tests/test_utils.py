import mock
import pytest

from dmaws.utils import run_cmd, run_piped_cmds, CalledProcessError
from dmaws.utils import safe_path_join
from dmaws.utils import dict_from_path, merge_dicts
from dmaws.utils import DEFAULT_TEMPLATES_PATH
from dmaws.utils import template, template_string, LazyTemplateMapping
from dmaws.utils import mkdir_p


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


class TestRunPipedCmds(object):
    def test_run_piped_cmds(self, subprocess):
        subprocess.PIPE = 'mypipe'
        pipe1 = mock.Mock(stdout='p1stdout')
        pipe2 = mock.Mock(returncode=0)
        pipe2.communicate.return_value = ('out', 'err')
        subprocess.Popen.side_effect = [
            pipe1, pipe2
        ]

        run_piped_cmds([
            ["ls"],
            ["cat"],
        ])

        assert subprocess.Popen.call_args_list == [
            mock.call(["ls"],
                      env={}, stdout=subprocess.PIPE, stderr=mock.ANY, stdin=None, cwd=None),
            mock.call(["cat"],
                      env={}, stdout=None, stderr=mock.ANY, stdin='p1stdout', cwd=None),
        ]

    def test_env_is_set_to_all_procs(self, os_environ, subprocess):
        os_environ.update({"OS": "1"})
        pipe1 = mock.Mock(stdout='p1stdout')
        pipe2 = mock.Mock(returncode=0)
        pipe2.communicate.return_value = ('out', 'err')
        subprocess.Popen.side_effect = [
            pipe1, pipe2
        ]

        run_piped_cmds([['ls'], ['cat']], env={"ENV": "2"})

        assert subprocess.Popen.call_args_list == [
            mock.call(['ls'], env={"OS": "1", "ENV": "2"}, stdout=mock.ANY, stderr=mock.ANY, stdin=mock.ANY,
                      cwd=mock.ANY),
            mock.call(['cat'], env={"OS": "1", "ENV": "2"}, stdout=mock.ANY, stderr=mock.ANY, stdin=mock.ANY,
                      cwd=mock.ANY),
        ]


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
