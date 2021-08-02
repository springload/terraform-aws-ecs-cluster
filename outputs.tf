output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "asg_arn" {
  value = var.instances_desired > 0 ? aws_autoscaling_group.ASG[0].arn : null
}
