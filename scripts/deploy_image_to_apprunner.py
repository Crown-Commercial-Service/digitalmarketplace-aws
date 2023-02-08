#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import copy
import json
import sys

import boto3
import click

sys.path.insert(0, ".")  # noqa - For the import of dmaws module

from dmaws.utils import read_yaml_file


def _get_service_by_name(service_name, client):
    match = [
        s
        for s in client.list_services()["ServiceSummaryList"]
        if s["ServiceName"] == service_name
    ]
    return match[0] if len(match) else None


def _build_service_env_vars(environment, app_name, supplied_env_vars):
    """
    Add conventional env vars to those supplied by config YML.

    This is analaogous with the previous behaviour of Manifest files being compiled
    by Jinja2 - The following variables are those defaulted in the former
    _base.j2 template file.

    """
    vars_dict = copy.copy(supplied_env_vars)
    vars_dict["DM_ENVIRONMENT"] = environment
    vars_dict["DM_APP_NAME"] = app_name
    return vars_dict


@click.command()
@click.argument("project")
@click.argument("environment", nargs=1, type=click.Choice(["staging"]))
@click.argument("app-name")
@click.argument("tf-outputs-json", type=click.File("rb"))
@click.option(
    "--image-tag",
    default="latest",
    help="Version tag of Docker image in repo (default: 'latest')",
)
def deploy_image_to_apprunner(
    project, environment, app_name, tf_outputs_json, image_tag
):
    """
    Deploy a Docker image from ECR into a named AppRunner service.

    PROJECT is the name of the system / namespace (e.g. "digitalmarketplace")

    ENVIRONMENT is the name of the target environment (see function decorator for legal values)

    APP_NAME is the name of the application (e.g. "buyer-frontend")

    TF_OUTPUTS_JSON is a streamed JSON string of outputs object from `terraform output -json`

    """
    print(
        f"Started with params {click.get_current_context().params}",
    )
    config_filename = f"infrastructure-aws/config/{environment}.yml"
    print(f"Loading config from {config_filename}")
    config = read_yaml_file(config_filename)

    tf_outputs = json.loads(tf_outputs_json.read())

    env_vars = _build_service_env_vars(
        environment=environment,
        app_name=app_name,
        supplied_env_vars=config[app_name]["environment"],
    )

    apprunner_service_name = f"{project}-{app_name}"
    app_name_snake = app_name.replace("-", "_")

    apprunner_build_iam_role_arn = tf_outputs["apprunner_build_iam_role_arn"]["value"]
    repo_url_var_name = f"ecr_repo_{app_name_snake}_url"
    ecr_image_identifier = tf_outputs[repo_url_var_name]["value"] + ":" + image_tag

    apprunner_client = boto3.client("apprunner")

    service = _get_service_by_name(
        service_name=apprunner_service_name, client=apprunner_client
    )
    if service:
        print(
            "Located service '{}' with ServiceId {} - starting deployment only".format(
                apprunner_service_name, service["ServiceId"]
            )
        )
        response = _start_deployment(service=service, client=apprunner_client)
    else:
        print("Service '{}' not found - creating anew".format(apprunner_service_name))
        response = _create_service(
            service_name=apprunner_service_name,
            image_identifier=ecr_image_identifier,
            build_role_arn=apprunner_build_iam_role_arn,
            env_vars=env_vars,
            client=apprunner_client,
        )

    print("Requested. Response: {}".format(response))


def _create_service(service_name, image_identifier, build_role_arn, env_vars, client):
    return client.create_service(
        ServiceName=service_name,
        SourceConfiguration={
            "ImageRepository": {
                "ImageIdentifier": image_identifier,
                "ImageConfiguration": {
                    "Port": "80",  # TODO make this into an arg
                    "RuntimeEnvironmentVariables": env_vars,
                },
                "ImageRepositoryType": "ECR",
            },
            "AutoDeploymentsEnabled": False,
            "AuthenticationConfiguration": {"AccessRoleArn": build_role_arn},
        },
        HealthCheckConfiguration={"Path": "/"},  # TODO make arg
    )


def _start_deployment(service, client):
    return client.start_deployment(ServiceArn=service["ServiceArn"])


if __name__ == "__main__":
    deploy_image_to_apprunner()
