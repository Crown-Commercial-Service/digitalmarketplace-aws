# infrastructure-aws

Proof of Concept: Deploying existing applications within an AWS native environment.

## Folder structure

The folder contains sub-folders, each with a different purpose:

* [environments](./environments/README.md) - Collection of sub-folders, each describing the compositional characteristics of the project within one particular environment
* [compositions](./compositions/README.md) - A layer of abstraction between Environments and classic modules
* [modules](./modules/README.md) - Re-usable collections of resources which provide some singular function of business value)
* [data-source-groups](./data-source-groups/README.md) - References to existing AWS resources whose properties are required during the application of Terraform
* [resource-groups](./resource-groups/README.md) - Collections of resources grouped for convenience based on commonality of implementation requirements


## IAM resource naming

### Roles

Roles will be named with the following components, separated with hyphens:

* Project name (e.g. 'digitalmarketplace')
* Environment name (e.g. 'staging')
* Descriptive name of the service which will be adopting this role
* The string "service" for clarity

(e.g. 'digitalmarketplace-staging-apprunner-build-service')

This must be kept within the maximum Role name length of *64 characters*.

### Policies

Policies will be named with the following components, separated with hyphens:

* Project name (e.g. 'digitalmarketplace')
* Environment name (e.g. 'staging')
* Descriptive name of the resource to which the policy applies, made up of:
  * Type of resource
  * "Common name" of resource
* Simple description of the permissions granted

(e.g. 'digitalmarketplace-staging-ecr-repo-api-read')

This must be kept within the maximum Permission name length of *128 characters*.

## Resource tagging
