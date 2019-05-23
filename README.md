# terraform-aws-ecs-cluster for terraform >= 0.12

This module configures ECS-cluster consisting of number of ec2 instances. It supports spot ec2 instances, which might be
cost effective for a development environment that allows some downtime.

## Required variables

Only `cluster_name` is required to be set.
