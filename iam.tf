resource "aws_iam_role" "ec2-role" {
  name = var.cluster_name

  assume_role_policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
    EOT

}

locals {
  managed_roles = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ]
}

resource "aws_iam_role_policy_attachment" "ec2-role-attach" {
  role = aws_iam_role.ec2-role.name

  count = length(local.managed_roles)
  policy_arn = element(local.managed_roles, count.index)
}

resource "aws_iam_instance_profile" "ec2-instance-role" {
  name = var.cluster_name
  role = aws_iam_role.ec2-role.name
}

