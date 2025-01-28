provider "aws" {
  region = var.aws_region
}

data "aws_route53_zone" "hosted_zone" {
  name = var.root_domain
}

resource "aws_route53_record" "subdomains" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.bastion_record_name
  type    = "A"
  ttl     = 300
  records = [var.bastion_public_ip]
}
