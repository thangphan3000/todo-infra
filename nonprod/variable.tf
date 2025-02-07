#
# Common
#

variable "project" {
  type    = string
  default = "cozy-todo"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "credential_key_name" {
  type    = string
  default = "key_name"
}

#
# Networking
#

variable "vpc_cidr" {
  type = string
}

variable "public_subnets_cidr" {
  type = list(string)
}

variable "private_subnets_cidr" {
  type = list(string)
}

variable "trusted_subnets_cidr" {
  type = list(string)
}

variable "keypair_path" {
  type    = string
  default = "./keypair/operation.pub"
}

variable "private_keypair_path" {
  type = string
}

variable "instance_types" {
  type = map(string)
  default = {
    "prod" : "t3.micro",
    "nonprod" : "t2.micro",
    "dev" : "t2.micro",
  }
}

#
# Instance type and AMI
#

variable "bastion_ami" {
  type    = string
  default = "ami-0c4e27b0c52857dd6"
}

variable "db_ami" {
  type    = string
  default = "ami-0672fd5b9210aa093"
}

#
# Database
#

variable "db_config" {
  type = object({
    username = string
    password = string
    name     = string
    engine = object({
      type    = string
      version = string
    })
    port                      = number
    allocated_storage         = number
    instance_class            = string
    backup_retention_period   = number
    storage_type              = string
    final_snapshot_identifier = string
  })
}

#
# Compute
#

variable "eks_config" {
  type = object({
    kubernetes_version = string
    node_group = object({
      name                 = string
      capacity_type        = string
      instance_type        = string
      max_unavailable_node = number
      scaling_config = object({
        desired_size = number
        min_size     = number
        max_size     = number
      })
    })
  })
}

#
# DNS
#

variable "root_domain" {
  type    = string
  default = "cozy-todo.click"
}

variable "bastion_record_name" {
  type    = string
  default = "bastion"
}
