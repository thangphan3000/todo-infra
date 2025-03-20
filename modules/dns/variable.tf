variable "environment" {
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

variable "bastion_public_ip" {
  type     = string
  nullable = false
}

variable "subdomains" {
  type = map(object({
    name      = string
    public_ip = string
    type      = string
    ttl       = number
  }))
}
