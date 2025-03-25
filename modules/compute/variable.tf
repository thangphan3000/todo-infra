variable "environment" {
  type     = string
  nullable = false
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "key_name" {
  type     = string
  nullable = false
}

variable "bastion_sg_id" {
  type     = string
  nullable = false
}

variable "vpn_server_sg_id" {
  type     = string
  nullable = false
}

variable "eks_node_sg_id" {
  type     = string
  nullable = false
}

variable "public_subnet_id" {
  type     = string
  nullable = false
}

variable "private_subnet_ids" {
  type     = list(string)
  nullable = false
}

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
  type = string
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
