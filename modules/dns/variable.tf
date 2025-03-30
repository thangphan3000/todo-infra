variable "environment" {
  type     = string
  nullable = false
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "root_domain" {
  type     = string
  nullable = false
}

variable "vpn_server_public_ip" {
  type     = string
  nullable = false
}

variable "eks_node_private_ip" {
  type     = string
  nullable = false
}

variable "bastion_public_ip" {
  type     = string
  nullable = false
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
