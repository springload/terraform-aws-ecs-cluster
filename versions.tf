terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0, < 6"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
    }
  }
}
