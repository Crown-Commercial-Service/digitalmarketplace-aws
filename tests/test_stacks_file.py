import json

from dmaws.stacks import Stack
from dmaws.context import Context


def is_true(x):
    assert x


def is_in(a, b):
    assert a in b


def valid_stack_json(stack):
    text = stack.build('stage', 'env', {}).template_body
    template = json.loads(text)

    assert 'Parameters' in template
    assert set(template['Parameters']) == set(stack.parameters)
    assert 'Resources' in template


def test_stack_definitions():
    ctx = Context()
    ctx.load_stacks('stacks.yml')

    yield('Found stacks in the stacks.yml',
          is_true, any(isinstance(s, Stack) for s in ctx.stacks.values()))
    yield('Found groups in stacks.yml',
          is_true, any(isinstance(s, list) for s in ctx.stacks.values()))

    for name, stack in ctx.stacks.items():
        if isinstance(stack, list):
            for s in stack:
                yield('Stack "%s" in group %s is defined' % (s, name),
                      is_in, s, ctx.stacks)
        else:
            for s in stack.dependencies:
                yield('%s dependency "%s" is defined' % (name, s),
                      is_in, s, ctx.stacks)
            yield('Stack "%s" template_body is valid JSON' % name,
                  valid_stack_json, stack)
