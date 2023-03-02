#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json

import boto3
import click


@click.command()
@click.argument("tf-outputs-json", type=click.File("rb"))
def run_migration_ecs_task(tf_outputs_json):
    """
    Run migration task at ECS.

    TF_OUTPUTS_JSON is a streamed JSON string of outputs object from `terraform output -json`

    """
    print(
        f"Started with params {click.get_current_context().params}",
    )

    tf_outputs = json.loads(tf_outputs_json.read())
    db_access_security_group_id = tf_outputs["db_access_security_group_id"]["value"]
    db_migration_ecs_task_definition_arn = tf_outputs[
        "db_migration_ecs_task_definition_arn"
    ]["value"]
    ecs_cluster_arn = tf_outputs["ecs_cluster_arn"]["value"]
    egress_all_security_group_id = tf_outputs["egress_all_security_group_id"]["value"]
    private_subnet_ids = tf_outputs["private_subnet_ids"]["value"]

    ecs_client = boto3.client("ecs")
    response = ecs_client.run_task(
        cluster=ecs_cluster_arn,
        count=1,
        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": private_subnet_ids,
                "securityGroups": [
                    db_access_security_group_id,
                    egress_all_security_group_id,
                ],
                "assignPublicIp": "DISABLED",
            }
        },
        taskDefinition=db_migration_ecs_task_definition_arn,
    )
    print("Migration requested.")

    task_arn = response["tasks"][0]["taskArn"]

    print(f"Waiting for completion of task {task_arn}")
    waiter = ecs_client.get_waiter("tasks_stopped")
    waiter.wait(cluster=ecs_cluster_arn, tasks=[task_arn])

    print("Done.")


if __name__ == "__main__":
    run_migration_ecs_task()
