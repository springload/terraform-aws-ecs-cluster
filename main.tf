resource "aws_launch_template" "LT" {
  name = var.spot ? "${var.cluster_name}-spot" : var.cluster_name

  dynamic instance_market_options {
    for_each = var.spot ? [1] : []

    content {
      market_type = "spot"
    }
  }

  credit_specification {
    cpu_credits = var.cpu_unlimited ? "unlimited" : "standard"
  }

  image_id               = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.group.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2-instance-role.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = var.disk_encrypted
    }
  }

  key_name   = var.ec2_key_name
  user_data  = data.template_cloudinit_config.config.rendered
  depends_on = [aws_iam_instance_profile.ec2-instance-role]
}

resource "aws_autoscaling_group" "ASG" {
  name     = var.cluster_name
  max_size = var.instances_desired
  min_size = var.instances_desired

  desired_capacity = var.instances_desired

  force_delete = true

  launch_template {
    id      = aws_launch_template.LT.id
    version = "$Latest"
  }

  vpc_zone_identifier  = coalescelist(var.subnet_ids, data.aws_subnet_ids.subnets.ids)
  termination_policies = ["OldestInstance"]

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

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [aws_iam_instance_profile.ec2-instance-role]
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

