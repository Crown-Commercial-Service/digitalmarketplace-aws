#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json

import boto3
import click


def _get_service_by_name(service_name, client):
    match = [
        s
        for s in client.list_services()["ServiceSummaryList"]
        if s["ServiceName"] == service_name
    ]
    return match[0] if len(match) else None


@click.command()
@click.argument("project")
@click.argument("app")
@click.argument("tf-outputs-json")
@click.option(
    "--image-tag",
    default="latest",
    help="Version tag of Docker image in repo (default: 'latest')",
)
def deploy_image_to_apprunner(project, app, tf_outputs_json, image_tag):
    """
    Deploy a Docker image from ECR into a named AppRunner service.

    PROJECT is the name of the system / namespace (e.g. "digitalmarketplace")

    APP is the name of the service (e.g. "buyer-frontend")

    TF_OUTPUTS_JSON is a JSON string of outputs object from `terraform output -json`

    """
    tf_outputs = json.loads(tf_outputs_json)
    apprunner_service_name = f"{project}-{app}"
    app_snake = app.replace("-", "_")
    repo_url_var_name = f"ecr_repo_url_{app_snake}"
    apprunner_build_iam_role_arn = tf_outputs["apprunner_build_iam_role_arn"]["value"]
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
            client=apprunner_client,
        )

    print("Requested. Response: {}".format(response))


def _create_service(service_name, image_identifier, build_role_arn, client):
    return client.create_service(
        ServiceName=service_name,
        SourceConfiguration={
            "ImageRepository": {
                "ImageIdentifier": image_identifier,
                "ImageConfiguration": {
                    "Port": "80",  # TODO make this into an arg
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
