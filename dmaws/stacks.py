from toposort import toposort_flatten

from .cloudformation import Cloudformation
from .utils import template, load_file


class Stack(object):
    def __init__(self, name, template, parameters, dependencies=None):
        self.name = name
        self.template = template
        self.parameters = parameters
        self.dependencies = dependencies or []

    def build(self, variables):
        return BuiltStack(self, variables)


class BuiltStack(Stack):
    def __init__(self, stack, variables):
        self.name = template(stack.name, variables)
        self.parameters = template(stack.parameters, variables)

        self.template = stack.template
        self.dependencies = stack.dependencies

        self.template_body = load_file(stack.template)

        self.status = None
        self.outputs = None
        self.resources = None

    def update_info(self, stack_info):
        for attr in ['status', 'outputs', 'resources']:
            setattr(self, attr, stack_info[attr])


class StackPlan(object):
    def __init__(self, stacks, variables, apps, logger=None):
        self.log = logger
        self.cfn = Cloudformation(variables['aws_region'], logger=self.log)

        self.apps = sorted(flatten_stack_groups(stacks, apps))
        self.stacks = get_stacks(stacks, self.apps, with_dependencies=True)
        self.stack_context = variables
        if 'stacks' in variables:
            raise ValueError("'stacks' is a reserved variable name")
        self.stack_context['stacks'] = {}

    def create(self):
        self.log('Creating %s', ', '.join(self.apps))
        self.log('Will run %s stacks', ', '.join(s[0] for s in self.stacks))

        for name, stack in self.stacks:
            built_stack = stack.build(self.stack_context)
            self.stack_context['stacks'][name] = built_stack

            stack_info = self.cfn.create_stack(built_stack)
            self.stack_context['stacks'][name].update_info(stack_info)

    @classmethod
    def from_ctx(cls, ctx):
        return cls(stacks=ctx.stacks, variables=ctx.variables, apps=ctx.apps, logger=ctx.log)


def get_stacks(stacks, names, with_dependencies=False):
    if with_dependencies:
        names = get_dependencies(stacks, names)

    return [(name, stacks[name]) for name in names]


def flatten_stack_groups(stacks, names):
    names = set(names)
    for name in names.copy():
        if isinstance(stacks[name], list):
            names.remove(name)
            names = names.union(flatten_stack_groups(stacks, stacks[name]))

    return names


def get_dependencies(stacks, names):
    return toposort_flatten(_get_dependencies(stacks, names))


def _get_dependencies(stacks, names):
    deps = {}
    for name in names:
        dependencies = stacks[name].dependencies
        deps[name] = set(dependencies)
        for dep in dependencies:
            deps.update(_get_dependencies(stacks, [dep]))

    return deps
