#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json

import boto3
import click


@click.command()
@click.argument("app-name")
@click.argument("tf-outputs-json", type=click.File("rb"))
def force_ecs_deployment(app_name, tf_outputs_json):
    """
    Deploy a new Task version at ECS.

    APP_NAME is the name of the application (e.g. "buyer-frontend")

    TF_OUTPUTS_JSON is a streamed JSON string of outputs object from `terraform output -json`

    """
    print(
        f"Started with params {click.get_current_context().params}",
    )

    tf_outputs = json.loads(tf_outputs_json.read())
    ecs_cluster_arn = tf_outputs["ecs_cluster_arn"]["value"]
    ecs_service_arn = tf_outputs["ecs_services_arns"]["value"][app_name]

    ecs_client = boto3.client("ecs")
    response = ecs_client.update_service(
        cluster=ecs_cluster_arn, service=ecs_service_arn, forceNewDeployment=True
    )

    print("Requested. Response: {}".format(response))


if __name__ == "__main__":
    force_ecs_deployment()
