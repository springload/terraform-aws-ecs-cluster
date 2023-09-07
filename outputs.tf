output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "asg_arn" {
  value = var.instances_desired > 0 || var.instances_autoscale_max > 0 ? aws_autoscaling_group.ASG[0].arn : null
}

output "asg_name" {
  value = var.instances_desired > 0 || var.instances_autoscale_max > 0 ? aws_autoscaling_group.ASG[0].name : null
}
