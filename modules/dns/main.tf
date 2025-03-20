locals {
  public_ips = {
    "bastion-ip"    = var.bastion_public_ip
    "vpn-server-ip" = var.vpn_server_public_ip
  }
}

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

resource "aws_route53_record" "subdomain" {
  for_each = var.subdomains
  name     = "${var.environment}.${each.value.name}"
  zone_id  = data.aws_route53_zone.root_domain.zone_id
  type     = each.value.type
  ttl      = each.value.ttl
  records  = [local.public_ips[each.value.public_ip]]
}
