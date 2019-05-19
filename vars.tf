# required variables
#
variable "cluster_name" {}

# optional variables
#

# Name of the AMI image to use.
variable "ami" {
  default = "amzn2-ami-ecs-hvm-*-x86_64-ebs"
}

# Whether or not enable t2/t3 cpu unlimited (if true, might incur additional charges)
variable "cpu_unlimited" {
  default = false
}

# EC2 key name to attach to newly created EC2 instances
variable "ec2_key_name" {
  default = ""
}

# EC2 instance type
variable "instance_type" {
  default = "t3.micro"
}

# Number of EC2 instances desired
variable "instances_desired" {
  default = 1
}

# security group names
variable "security_groups" {
  type    = "list"
  default = []
}

# Whether or not use Spot instances
# Warning: most likely not suitable for production!
variable "spot" {
  default = false
}

# VPC name. If not set, will default to "default"
variable "vpc_name" {
  default = ""
}
