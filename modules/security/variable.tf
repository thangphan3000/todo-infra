variable "aws_region" {
  type     = string
  nullable = false
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "environment" {
  type     = string
  nullable = false
}

variable "mgmt_subnets_cidr" {
  type     = list(string)
  nullable = false
}

variable "trusted_subnets_cidr" {
  type     = list(string)
  nullable = false
}
