variable "aws_region" {
  type     = string
  nullable = false
}

variable "environment" {
  type     = string
  nullable = false
}

variable "vpc_cidr" {
  type     = string
  nullable = false
}

variable "public_subnets_cidr" {
  type     = list(string)
  nullable = false
}

variable "private_subnets_cidr" {
  type     = list(string)
  nullable = false
}

variable "trusted_subnets_cidr" {
  type     = list(string)
  nullable = false
}
