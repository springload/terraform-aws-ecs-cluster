resource "aws_launch_template" "LT" {
  count = var.instances_desired > 0 || var.instances_autoscale_max > 0 ? 1 : 0

  name = var.spot ? "${var.cluster_name}-spot" : var.cluster_name

  dynamic "instance_market_options" {
    for_each = var.spot ? [1] : []

    content {
      market_type = "spot"
    }
  }

  credit_specification {
    cpu_credits = var.cpu_unlimited ? "unlimited" : "standard"
  }

  image_id = var.ami != "" ? data.aws_ami.ami[0].id : jsondecode(data.aws_ssm_parameter.recommended_ami[0].insecure_value).image_id

  instance_type          = var.instance_type
  vpc_security_group_ids = data.aws_security_group.group[*].id


  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [1] : []

    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#metadata-options
    content {
      http_endpoint               = lookup(var.metadata_options, "http_endpoint", "enabled")
      http_tokens                 = lookup(var.metadata_options, "http_tokens", "optional")
      http_put_response_hop_limit = lookup(var.metadata_options, "http_put_response_hop_limit", 1)
      http_protocol_ipv6          = lookup(var.metadata_options, "http_protocol_ipv6", "disabled")
      instance_metadata_tags      = lookup(var.metadata_options, "instance_metadata_tags", "disabled")
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2-instance-role.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = var.disk_type
      delete_on_termination = true
      encrypted             = var.disk_encrypted
    }
  }

  key_name   = var.ec2_key_name
  user_data  = data.cloudinit_config.config[0].rendered
  depends_on = [aws_iam_instance_profile.ec2-instance-role]
}

resource "aws_autoscaling_group" "ASG" {
  count = var.instances_desired > 0 || var.instances_autoscale_max > 0 ? 1 : 0

  name     = var.cluster_name
  max_size = var.instances_desired > 0 ? var.instances_desired : var.instances_autoscale_max
  min_size = var.instances_desired > 0 ? var.instances_desired : 0

  desired_capacity = var.instances_desired

  force_delete          = true
  protect_from_scale_in = var.instances_autoscale_max > 0 && var.instances_desired == 0 // if using autoscaling

  launch_template {
    id      = aws_launch_template.LT[0].id
    version = aws_launch_template.LT[0].latest_version
  }

  vpc_zone_identifier  = coalescelist(var.subnet_ids, tolist(data.aws_subnets.subnets.ids))
  termination_policies = ["OldestInstance"]

  dynamic "instance_refresh" {
    for_each = var.instance_refresh ? [1] : []

    content {
      strategy = "Rolling"
      triggers = ["launch_template"]
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-ecs"
    propagate_at_launch = true
  }

  tag {
    key                 = "ecs-cluster"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  // ecs autoscaling will add it otherwise and we'll get drift
  dynamic "tag" {
    for_each = var.instances_autoscale_max > 0 && var.instances_desired == 0 ? [{}] : []
    content {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [aws_iam_instance_profile.ec2-instance-role]

  lifecycle {
    // desired_capacity is managed by ECS
    ignore_changes = [desired_capacity]
  }
}

resource "aws_ecs_capacity_provider" "autoscale" {
  count = var.instances_autoscale_max > 0 && var.instances_desired == 0 ? 1 : 0

  name = "${var.cluster_name}-autoscale"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ASG[0].arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status = "ENABLED"
    }
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "providers" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = compact([
    var.instances_autoscale_max > 0 && var.instances_desired == 0 ? aws_ecs_capacity_provider.autoscale[0].name : "",
    "FARGATE",
    "FARGATE_SPOT",
  ])

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.instances_autoscale_max > 0 && var.instances_desired == 0 ? aws_ecs_capacity_provider.autoscale[0].name : "FARGATE"
  }
}

