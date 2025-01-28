variable "aws_region" {
  type     = string
  nullable = false
}

variable "root_domain" {
  type     = string
  nullable = false
}

variable "bastion_public_ip" {
  type     = string
  nullable = false
}

variable "bastion_record_name" {
  type     = string
  nullable = false
}
