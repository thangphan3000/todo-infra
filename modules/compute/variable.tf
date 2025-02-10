variable "aws_region" {
  type = string
}

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

variable "public_subnet_id" {
  type     = string
  nullable = false
}

variable "private_subnet_ids" {
  type     = list(string)
  nullable = false
}

variable "eks_config" {
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
