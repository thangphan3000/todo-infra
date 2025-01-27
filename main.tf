provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "operation_keypair" {
  key_name   = "operation-keypair"
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
  key_name              = aws_key_pair.operation_keypair.key_name
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.instance_types[var.environment]
  bastion_sg_id         = module.security.bastion_sg_id
  mgmt_subnet_id        = module.networking.mgmt_subnet_ids[0]
  db_ami                = var.db_ami
  db_instance_type      = var.db_instance_types[var.environment]
  db_sg_id              = module.security.db_sg_id
  db_master_sg_id       = module.security.db_master_id
  trusted_subnet_ids    = module.networking.trusted_subnet_ids
}
