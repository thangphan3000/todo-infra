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

variable "db_sg_id" {
  type     = string
  nullable = false
}

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
