# infrastructure-aws

Proof of Concept: Deploying existing applications within an AWS native environment.

## Pre-requisites

This list does not include pre-requisites for Terraform state management (i.e. S3 state bucket and Dynamo lock table).

### Route 53 Hosted Zone

A Hosted Zone needs to exist in the AWS account. This HZ will provide the DNS records for the environment you create.

The HZ needs to be reflected in the following Terraform vars: `domain_name`, `hosted_zone_id`. See the variables files for more information.

### Nginx basic auth credentials

The Nginx server baked into each frontend service requires a basic auth header to allow access to `/` and beyond. This is stored in Secrets Manager as a matter of best practice.

We also need to faciliate on-container health checks which exercise the WSGI code and this requires that we provide an auth header with those `curl` requests and that this header match the credentials.

For this reason there is also a requirement to provide a Secrets Manager secret before you apply the Terraform.

The secret should be created as follows:

Name: digitalmarketplace-ENVIRONMENT-proxy-credentials (e.g. "digitalmarketplace-staging-proxy-credentials")

Content:
```json
{  "auth_user":"poc",
   "auth_password":"some-password",   
   "htpasswd_string":"poc:$apr1$hashhashhash/"}
```

### Database creation

The RDS database instance is created by the Terraform however the schemata and fixtures will not be present. All services will fail startup repeatedly while this is the case.

Initialise the database structure by running the migrations thus, after the Terraform has first been applied:

```bash
make deploy-db-migration-aws-native
```

Note that this assumes two things:

1. The shell environment has AWS CLI access configured
1. The configured user has IAM permissions to run ECS RunTask on the appropriate task definition (the ARN for this task definition is provided in the Terraform output as `db_migration_ecs_task_definition_arn`).

See [this doc](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonelasticcontainerservice.html#amazonelasticcontainerservice-actions-as-permissions) for more information on the RunTask API method and the IAM permissions required to invoke it.

In the time between Terraform application and running this migration, the services will repeatedly fail to start, as stated above. Once migration has been run, the services will self-heal automatically.

*Note:* The migration script waits until the ECS task is complete. This can take around a minute.

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

Currently we only use default tags for resources created for the POC. These are defined in a *provider.tf* file in each environment, for example [this one](./environments/staging/provider.tf) in the POC Staging environment.

All taggable resources will receive the tags as defined in that file.
