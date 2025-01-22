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
  default     = ""
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

variable "disk_type" {
  type        = string
  description = "EBS volume type"
  default     = "gp2"
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

variable "instance_refresh" {
  type        = bool
  description = "Whether or not refresh the ASG when LT is updated"
  default     = false
}

variable "instances_desired" {
  type        = number
  description = "Number of EC2 instances desired"
  default     = 0
}
variable "instances_autoscale_max" {
  type        = number
  description = "The maximum number of EC2 instances when using autoscaling"
  default     = 10
}

variable "metadata_options" {
  type        = map(any)
  description = "Map of metadata options"
  default     = {}
}

variable "security_groups" {
  type        = list(any)
  description = "list of security group names"
  default     = []
}

variable "subnet_ids" {
  description = "list of subnet ids. By default takes all subnets from the VPC"
  type        = list(any)
  default     = []
}

variable "spot" {
  type        = bool
  description = "Whether or not use Spot instances. Warning: most likely not suitable for production!"
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "instances tags"
  default     = {}
}

variable "vpc_name" {
  type        = string
  description = "VPC name. If not set, will default to \"default\""
  default     = ""
}

variable "disk_kms_key_id" {
  type        = string
  description = "KMS key ID for EBS volume encryption. Using AWS managed key by default."
  default     = "alias/aws/ebs"
}