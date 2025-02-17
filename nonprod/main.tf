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
  private_subnets_cidr = var.private_subnets_cidr
}

module "container_registry" {
  source      = "../modules/container-registry"
  aws_region  = var.aws_region
  project     = var.project
  environment = var.environment
}

module "compute" {
  source                = "../modules/compute"
  aws_region            = var.aws_region
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  key_name              = module.credential.key_name
  bastion_private_key   = file(var.private_keypair_path)
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.instance_types[var.environment]
  bastion_sg_id         = module.security.bastion_sg_id
  public_subnet_id      = module.networking.public_subnet_ids[0]
  private_subnet_ids    = module.networking.private_subnet_ids
  eks_config            = var.eks_config
}

module "database" {
  source             = "./modules/database"
  aws_region         = var.aws_region
  environment        = var.environment
  db_config          = var.db_config
  db_sg_id           = module.security.db_sg_id
  trusted_subnet_ids = module.networking.trusted_subnet_ids
}

module "dns" {
  source              = "../modules/dns"
  aws_region          = var.aws_region
  environment         = var.environment
  root_domain         = var.root_domain
  bastion_record_name = var.bastion_record_name
  bastion_public_ip   = module.compute.bastion_public_ip
}

provider "helm" {
  kubernetes {
    host                   = module.compute.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.compute.eks_cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.compute.eks_cluster_name]
      command     = "aws"
    }
  }
}
