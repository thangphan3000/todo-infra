locals {
  ips = {
    "bastion-ip"    = var.bastion_public_ip
    "vpn-server-ip" = var.vpn_server_public_ip
    "grafana-ip"    = var.eks_node_private_ip
  }
}

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

resource "aws_route53_zone" "private" {
  name = "cozy-todo.click"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "subdomain" {
  for_each = var.subdomains
  name     = "${var.environment}.${each.value.name}"
  zone_id  = each.value.hosted_zone_type == "public" ? data.aws_route53_zone.root_domain.zone_id : aws_route53_zone.private.zone_id
  type     = each.value.record_type
  ttl      = each.value.ttl
  records  = [local.ips[each.value.ip]]
}
