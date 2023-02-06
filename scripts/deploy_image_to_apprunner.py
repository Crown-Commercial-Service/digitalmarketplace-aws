#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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
@click.argument("image-identifier")
@click.argument("apprunner-service-name")
@click.argument("build-role-arn")
def deploy_image_to_apprunner(image_identifier, apprunner_service_name, build_role_arn):
    """
    Deploy a Docker image from ECR into a named AppRunner service.

    IMAGE_IDENTIFIER id the identifier for Docker image to pull from ECR, as a URI. Ignored if named service exists.

    APPRUNNER_SERVICE_NAME is the unique ServiceName of AppRunner service - will be created if not already in existence.

    BUILD_ROLE_ARN is the ARN of IAM role which grants App Runner Builder access to the ECR repository. Ignored if named service exists.
    """

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
            image_identifier=image_identifier,
            build_role_arn=build_role_arn,
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
