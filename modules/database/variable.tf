variable "aws_region" {
  type = string
}

variable "environment" {
  type     = string
  nullable = false
}

variable "trusted_subnet_ids" {
  type     = list(string)
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

variable "db_name" {
  type     = string
  nullable = false
}

variable "db_sg_id" {
  type     = string
  nullable = false
}

variable "db_instance_class" {
  type     = string
  nullable = false
}

variable "db_port" {
  type     = number
  nullable = false
}

variable "db_allocated_storage" {
  type     = string
  nullable = false
}

variable "db_storage_type" {
  type     = string
  nullable = false
}

variable "db_backup_retention_period" {
  type     = number
  nullable = false
}

variable "db_final_snapshot_identifier" {
  type     = string
  nullable = false
}
