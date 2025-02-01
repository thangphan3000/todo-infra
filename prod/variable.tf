#
# Common
#

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
  type    = string
  default = "./keypair/operation"
}

variable "instance_types" {
  type = map(string)
  default = {
    "prod" : "t3.micro",
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

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "db_instance_class" {
  type    = string
  default = "db.m5d.large"
}

variable "db_storage_type" {
  type    = string
  default = "gp3"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_backup_retention_period" {
  type    = number
  default = 7
}

variable "db_final_snapshot_identifier" {
  type    = string
  default = "app-db-snapshot"
}

variable "db_engine_version" {
  type    = string
  default = "8.0.40"
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
