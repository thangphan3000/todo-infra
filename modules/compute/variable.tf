variable "aws_region" {
  type = string
}

variable "environment" {
  type     = string
  nullable = false
}

variable "key_name" {
  type     = string
  nullable = false
}

variable "bastion_private_key" {
  type     = string
  nullable = false
}

variable "bastion_ami" {
  type     = string
  nullable = false
}

variable "bastion_instance_type" {
  type     = string
  nullable = false
}

variable "bastion_sg_id" {
  type     = string
  nullable = false
}

variable "mgmt_subnet_id" {
  type     = string
  nullable = false
}

variable "trusted_subnet_ids" {
  type     = list(string)
  nullable = false
}
