variable "aws_region" {
  type = string
}

variable "environment" {
  type     = string
  nullable = false
}

variable "db_username" {
  type     = string
  nullable = false
}

variable "db_password" {
  type     = string
  nullable = false
}

variable "db_sg_id" {
  type     = string
  nullable = false
}

variable "trusted_subnet_ids" {
  type     = list(string)
  nullable = false
}
