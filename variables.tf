# required variables
#
variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

# optional variables
#

variable "ami" {
  type        = string
  description = "Name of the AMI image to use"
  default     = "amzn2-ami-ecs-hvm-*-x86_64-ebs"
}

variable "cloud_init_parts" {
  type        = list(map(string))
  description = "Allows to provide additional cloud-init parts"
  default     = []
}

variable "cpu_unlimited" {
  type        = bool
  description = "Whether or not enable t2/t3 cpu unlimited (if true, might incur additional charges)"
  default     = false
}

variable "disk_encrypted" {
  type        = bool
  description = "Whether or not encrypt the EBS volume"
  default     = true
}

variable "disk_size" {
  type        = number
  description = "EBS volume size"
  default     = 30
}

variable "ec2_key_name" {
  type        = string
  description = "EC2 key name to attach to newly created EC2 instances"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instances_desired" {
  type        = number
  description = "Number of EC2 instances desired"
  default     = 1
}

variable "security_groups" {
  type        = list
  description = "list of security group names"
  default     = []
}

variable "subnet_ids" {
  description = "list of subnet ids. By default takes all subnets from the VPC"
  type        = list
  default     = []
}

variable "spot" {
  type        = bool
  description = "Whether or not use Spot instances. Warning: most likely not suitable for production!"
  default     = false
}

variable "tags" {
  type        = map
  description = "instances tags"
  default     = {}
}

variable "vpc_name" {
  type        = string
  description = "VPC name. If not set, will default to \"default\""
  default     = ""
}
