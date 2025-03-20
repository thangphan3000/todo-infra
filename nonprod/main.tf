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
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnets_cidr = var.private_subnets_cidr
}

module "container_registry" {
  source      = "../modules/container-registry"
  project     = var.project
  environment = var.environment
}

module "compute" {
  source                   = "../modules/compute"
  environment              = var.environment
  vpc_id                   = module.networking.vpc_id
  key_name                 = module.credential.key_name
  vms                      = var.vms
  bastion_sg_id            = module.security.bastion_sg_id
  vpn_server_sg_id         = module.security.vpn_server_sg_id
  public_subnet_id         = module.networking.public_subnet_ids[0]
  private_subnet_ids       = module.networking.private_subnet_ids
  eks_cluster_config       = var.eks_cluster_config
  eks_node_sg_id           = module.security.eks_node_sg_id
  eks_node_launch_template = var.eks_node_launch_template
  eks_secretsmanager_arn   = var.eks_secretsmanager_arn
  helm_releases            = var.helm_releases
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
  source               = "../modules/dns"
  environment          = var.environment
  root_domain          = var.root_domain
  subdomains           = var.subdomains
  bastion_public_ip    = module.compute.bastion_public_ip
  eks_node_private_ip  = module.compute.eks_node_private_ip
  vpc_id               = module.networking.vpc_id
  vpn_server_public_ip = module.compute.vpn_server_public_ip
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
