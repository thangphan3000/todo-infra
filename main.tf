provider "aws" {
  region = var.aws_region
}

locals {
  project_name = var.project_name
}

data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.bastion_record_name
  type    = "A"
  ttl     = 300
  records = [module.compute.bastion_public_ip]
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = file(var.keypair_path)
}

module "networking" {
  source               = "./modules/networking"
  aws_region           = var.aws_region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  trusted_subnets_cidr = var.trusted_subnets_cidr
  mgmt_subnets_cidr    = var.mgmt_subnets_cidr
}

module "security" {
  source               = "./modules/security"
  aws_region           = var.aws_region
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  mgmt_subnets_cidr    = var.mgmt_subnets_cidr
  trusted_subnets_cidr = var.trusted_subnets_cidr
}

module "compute" {
  source                = "./modules/compute"
  aws_region            = var.aws_region
  environment           = var.environment
  key_name              = aws_key_pair.keypair.key_name
  bastion_private_key   = file(var.private_keypair_path)
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.instance_types[var.environment]
  bastion_sg_id         = module.security.bastion_sg_id
  mgmt_subnet_id        = module.networking.mgmt_subnet_ids[0]
  trusted_subnet_ids    = module.networking.trusted_subnet_ids
}

module "database" {
  source             = "./modules/database"
  aws_region         = var.aws_region
  environment        = var.environment
  db_username        = var.db_username
  db_password        = var.db_password
  db_sg_id           = module.security.db_sg_id
  trusted_subnet_ids = module.networking.trusted_subnet_ids
}
