import re

from toposort import toposort_flatten

from .cloudformation import Cloudformation
from .utils import template, load_file, LazyTemplateMapping
from .deploy import Deploy


class Stack(object):
    def __init__(self, name, template, parameters=None,
                 dependencies=None, repo_url=None):
        self.name = name
        self.repo_url = repo_url
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

        self.parameters = LazyTemplateMapping(
            stack.parameters,
            variables,
            stage=self.stage,
            environment=self.environment)

        self.template = stack.template
        self.dependencies = stack.dependencies

        self._template_body = None

        self.status = None
        self.outputs = None
        self.resources = None

    @property
    def template_body(self):
        if self._template_body is None:
            self._template_body = self._load_template()

        return self._template_body

    def _build_name(self, name):
        return template(name, {},
                        stage=self.stage, environment=self.environment)

    def _load_template(self):
        template_body = load_file(self.template)

        environment_variables = [
            p for p in self.parameters.keys() if p.startswith('EnvVar')
        ]

        def param_to_env(name):
            s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
            s2 = re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1)
            return s2.upper().replace('ENV_VAR_', '')

        return template(template_body, {
            "environment_variables": environment_variables,
            "param_to_env": param_to_env,
        })

    def update_info(self, stack_info):
        for attr in ['status', 'outputs', 'resources']:
            setattr(self, attr, stack_info[attr])


class StackPlan(object):
    def __init__(self, stacks, stage, environment, variables, apps,
                 logger=None, profile_name=None):
        self.log = logger or (lambda *args, **kwargs: None)
        self.profile_name = profile_name
        self.cfn = Cloudformation(variables['aws_region'], logger=self.log,
                                  profile_name=profile_name)

        self.stage = stage
        self.environment = environment
        self.apps = sorted(flatten_stack_groups(stacks, apps))
        self._stacks = stacks

        self.stack_context = variables.copy()
        if 'stacks' in variables:
            raise ValueError("'stacks' is a reserved variable name")
        self.stack_context['stacks'] = {}

    def stacks(self, apps=None, with_dependencies=False):
        apps = sorted(flatten_stack_groups(self._stacks, apps or self.apps))
        return get_stacks(self._stacks, apps or self.apps, with_dependencies)

    def dependant_stacks(self):
        return get_stacks(
            self._stacks,
            get_dependants(self._stacks, self.apps),
        )

    def build_stack(self, stack):
        return stack.build(self.stage, self.environment, self.stack_context)

    def get_value(self, path):
        vars_dict = self.stack_context
        for key in path.split('.'):
            try:
                vars_dict = vars_dict[key]
            except TypeError:
                vars_dict = getattr(vars_dict, key)
        return vars_dict

    def info(self, apps=None, with_aws=True):
        stacks = self.stacks(apps, with_dependencies=True)
        self.log('Gathering info about %s stacks',
                 ', '.join(s[0] for s in stacks))

        for name, stack in stacks:
            built_stack = self.build_stack(stack)
            self.stack_context['stacks'][name] = built_stack

            if with_aws:
                stack_info = self.cfn.describe_stack(built_stack)
                if stack_info:
                    self.stack_context['stacks'][name].update_info(stack_info)
                else:
                    self.log('Stack [%s] does not exist', name)

        return self.stack_context['stacks']

    def create(self, create_dependencies=True):
        self.log('Creating %s', ', '.join(self.apps))

        stacks = self.stacks(with_dependencies=True)
        self.log('Will run %s stacks', ', '.join(s[0] for s in stacks))

        for name, stack in stacks:
            built_stack = self.build_stack(stack)
            self.stack_context['stacks'][name] = built_stack

            if create_dependencies or name in self.apps:
                stack_info = self.cfn.create_stack(built_stack)
            else:
                stack_info = self.cfn.describe_stack(built_stack)
                if not stack_info:
                    self.log("Dependency %s doesn't exists, can't continue",
                             built_stack.name)
                    return False

            self.stack_context['stacks'][name].update_info(stack_info)

        return True

    def delete(self):
        self.log('Deleting %s', ', '.join(self.apps))

        stacks = self.dependant_stacks()
        self.log('Will check %s stacks', ', '.join(s[0] for s in stacks))

        for name, stack in stacks:
            built_stack = self.build_stack(stack)
            status = self.cfn.describe_stack(built_stack)
            if name in self.apps:
                self.cfn.delete_stack(built_stack)
            elif status and name not in self.apps:
                self.log("Dependant stack %s exists, can't continue",
                         built_stack.name)
                return False

        return True

    def get_deploy(self, repository_path=None):
        if len(self.apps) != 1:
            raise StandardError("Can only deploy a single app at a time")
        stack_info = self.info(with_aws=False)[self.apps[0]]

        return Deploy(
            stack_info.parameters['ApplicationName'],
            stack_info.parameters['EnvironmentName'],
            repository_path,
            region=self.stack_context['aws_region'],
            logger=self.log,
            profile_name=self.profile_name,
        )

    @classmethod
    def from_ctx(cls, ctx, **kwargs):
        return cls(
            stacks=kwargs.get('stacks', ctx.stacks),
            stage=kwargs.get('stage', ctx.stage),
            environment=kwargs.get('environment', ctx.environment),
            variables=kwargs.get('variables', ctx.variables),
            apps=kwargs.get('apps', ctx.apps),
            logger=kwargs.get('logger', ctx.log),
            profile_name=kwargs.get('profile_name'),
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


def get_dependants(stacks, names):
    return toposort_flatten(_get_dependants(stacks, names))


def _get_dependencies(stacks, names):
    deps = {}
    for name in names:
        dependencies = stacks[name].dependencies
        deps[name] = set(dependencies)
        for dep in dependencies:
            deps.update(_get_dependencies(stacks, [dep]))

    return deps


def _get_dependants(stacks, names):
    reversed_deps = _reversed_deps(stacks, names)

    return dict((name, set(reversed_deps.get(name, []))) for name in names)


def _reversed_deps(stacks, names):
    reversed_deps = {}
    for stack in filter(lambda s: isinstance(stacks[s], Stack), stacks):
        for dep in stacks[stack].dependencies:
            if dep in reversed_deps:
                reversed_deps[dep].append(stack)
            else:
                reversed_deps[dep] = [stack]

    return reversed_deps
