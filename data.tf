data "aws_vpc" "main" {
  default = var.vpc_name == "" ? true : false

  tags = var.vpc_name != "" ? {
    Name = var.vpc_name
  } : {}
}

data "aws_ami" "ami" {
  count = var.ami == "" ? 0 : 1

  most_recent = true

  filter {
    name = "name"

    values = [var.ami]
  }

  owners = ["amazon"]
}

data "aws_ssm_parameter" "recommended_ami" {
  count = var.ami == "" ? 1 : 0

  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}

data "aws_security_group" "group" {
  count = length(var.security_groups)

  filter {
    name   = "group-name"
    values = [var.security_groups[count.index]]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_kms_key" "ebs_default" {
  key_id = "alias/aws/ebs"
}pw