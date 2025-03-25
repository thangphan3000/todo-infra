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

#
# Security
#

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

variable "eks_cluster_config" {
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

variable "eks_node_launch_template" {
  type = object({
    name_prefix = string
    block_device_mappings = object({
      device_name = string
      ebs = object({
        volume_size = number
        volume_type = string
      })
    })
  })
}

variable "eks_secretsmanager_arn" {
  type     = string
  nullable = false
}

variable "helm_releases" {
  type = map(object({
    release = object({
      repository       = string
      chart            = string
      namespace        = string
      version          = string
      value_file_name  = optional(string)
      create_namespace = bool
    })
  }))
}

variable "vms" {
  type = map(object({
    instance = object({
      ami                         = string
      instance_type               = string
      associate_public_ip_address = bool
      sg_ids                      = list(string)
    })
  }))
}

#
# DNS
#

variable "root_domain" {
  type = string
}

variable "subdomains" {
  type = map(object({
    name             = string
    ip               = string
    record_type      = string
    ttl              = number
    hosted_zone_type = string
  }))

  validation {
    condition = alltrue([
      for subdomain in var.subdomains : contains(["public", "private"], subdomain.hosted_zone_type)
    ])
    error_message = "The 'hosted_zone_type' for each subdomain must be either 'public' or 'private'."
  }

  validation {
    condition = alltrue([
      for subdomain in var.subdomains : contains(["A", "CNAME"], subdomain.record_type)
    ])
    error_message = "The 'record_type' for each subdomain must be either 'A' or 'CNAME'."
  }
}
