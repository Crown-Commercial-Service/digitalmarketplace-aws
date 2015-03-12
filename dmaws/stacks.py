from toposort import toposort_flatten

from .cloudformation import Cloudformation
from .utils import template, load_file


class Stack(object):
    def __init__(self, name, template, parameters, dependencies=None):
        self.name = name
        self.template = template
        self.parameters = parameters or {}
        self.dependencies = dependencies or []

    def build(self, *args, **kwargs):
        return BuiltStack(self, *args, **kwargs)


class BuiltStack(Stack):
    def __init__(self, stack, stage, environment, variables):
        self.stage = stage
        self.environment = environment

        self.name = self._build_name(stack.name)

        self._parameters = None
        self._raw_parameters = stack.parameters
        self._variables = variables

        self.template = stack.template
        self.dependencies = stack.dependencies

        self.template_body = load_file(stack.template)

        self.status = None
        self.outputs = None
        self.resources = None

    @property
    def parameters(self):
        if self._parameters is None:
            parameters = template(
                self._raw_parameters,
                self._variables,
                stage=self.stage,
                environment=self.environment
            )
            self._parameters = parameters

        return self._parameters

    def _build_name(self, name):
        return template(name, {}, stage=self.stage, environment=self.environment)

    def update_info(self, stack_info):
        for attr in ['status', 'outputs', 'resources']:
            setattr(self, attr, stack_info[attr])


class StackPlan(object):
    def __init__(self, stacks, stage, environment, variables, apps, logger=None):
        self.log = logger
        self.cfn = Cloudformation(variables['aws_region'], logger=self.log)

        self.stage = stage
        self.environment = environment
        self.apps = sorted(flatten_stack_groups(stacks, apps))
        self.stacks = get_stacks(stacks, self.apps, with_dependencies=True)
        self.stack_context = variables
        if 'stacks' in variables:
            raise ValueError("'stacks' is a reserved variable name")
        self.stack_context['stacks'] = {}

    def stacks(self, with_dependencies=False):
        return get_stacks(self._stacks, self.apps, with_dependencies)

    def build_stack(self, stack):
        return stack.build(self.stage, self.environment, self.stack_context)

    def create(self):
        self.log('Creating %s', ', '.join(self.apps))

        stacks = self.stacks(with_dependencies=True)
        self.log('Will run %s stacks', ', '.join(s[0] for s in stacks))

        for name, stack in stacks:
            built_stack = self.build_stack(stack)
            self.stack_context['stacks'][name] = built_stack

            stack_info = self.cfn.create_stack(built_stack)
            self.stack_context['stacks'][name].update_info(stack_info)

    @classmethod
    def from_ctx(cls, ctx):
        return cls(
            stacks=ctx.stacks,
            stage=ctx.stage,
            environment=ctx.environment,
            variables=ctx.variables,
            apps=ctx.apps,
            logger=ctx.log
        )


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
