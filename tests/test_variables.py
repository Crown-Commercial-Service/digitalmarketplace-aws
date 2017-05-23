from dmaws.variables import get_variables_files


def test_get_variables_files():
    assert get_variables_files('stage', [], False) == []


def test_get_variables_files_with_vars_files():
    assert get_variables_files('stage', ['foo.yml'], False) == ['foo.yml']


def test_get_variables_files_with_default_files(path_exists):
    path_exists.return_value = False

    assert get_variables_files('stage', [], True) == [
        'vars/common.yml',
        'vars/stage.yml',
    ]


def test_get_variables_files_with_default_files_and_vars(path_exists):
    path_exists.return_value = False

    assert get_variables_files('stage', ['test.yml'], True) == [
        'vars/common.yml',
        'vars/stage.yml',
        'test.yml',
    ]
