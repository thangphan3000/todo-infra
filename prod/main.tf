provider "aws" {
  region = var.aws_region
}

module "credential" {
  source       = "../modules/credential"
  keypair_path = var.keypair_path
  key_name     = var.credential_key_name
}

module "networking" {
  source               = "../modules/networking"
  aws_region           = var.aws_region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  trusted_subnets_cidr = var.trusted_subnets_cidr
}

module "security" {
  source               = "../modules/security"
  aws_region           = var.aws_region
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  trusted_subnets_cidr = var.trusted_subnets_cidr
}

module "compute" {
  source                = "../modules/compute"
  aws_region            = var.aws_region
  environment           = var.environment
  key_name              = module.credential.key_name
  bastion_private_key   = file(var.private_keypair_path)
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.instance_types[var.environment]
  bastion_sg_id         = module.security.bastion_sg_id
  public_subnet_id      = module.networking.public_subnet_ids[0]
  private_subnet_ids    = module.networking.private_subnet_ids
}

module "database" {
  source                       = "../modules/database"
  aws_region                   = var.aws_region
  environment                  = var.environment
  db_engine_version            = var.db_engine_version
  db_port                      = var.db_port
  db_username                  = var.db_username
  db_password                  = var.db_password
  db_name                      = var.db_name
  db_instance_class            = var.db_instance_class
  db_storage_type              = var.db_storage_type
  db_allocated_storage         = var.db_allocated_storage
  db_backup_retention_period   = var.db_backup_retention_period
  db_final_snapshot_identifier = var.db_final_snapshot_identifier
  db_sg_id                     = module.security.db_sg_id
  trusted_subnet_ids           = module.networking.trusted_subnet_ids
}

module "dns" {
  source              = "./modules/dns"
  aws_region          = var.aws_region
  environment         = var.environment
  root_domain         = var.root_domain
  bastion_record_name = var.bastion_record_name
  bastion_public_ip   = module.compute.bastion_public_ip
}
