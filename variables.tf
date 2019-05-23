# required variables
#
variable "cluster_name" {
  description = "Name of the ECS cluster"
}

# optional variables
#

variable "ami" {
  description = "Name of the AMI image to use"
  default     = "amzn2-ami-ecs-hvm-*-x86_64-ebs"
}

variable "cpu_unlimited" {
  description = "Whether or not enable t2/t3 cpu unlimited (if true, might incur additional charges)"
  default     = false
}

variable "ec2_key_name" {
  description = "EC2 key name to attach to newly created EC2 instances"
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instances_desired" {
  description = "Number of EC2 instances desired"
  default     = 1
}

variable "security_groups" {
  description = "list of security group names"
  type        = "list"
  default     = []
}

variable "spot" {
  description = "Whether or not use Spot instances. Warning: most likely not suitable for production!"
  default     = false
}

variable "vpc_name" {
  description = "VPC name. If not set, will default to \"default\""
  default     = ""
}
