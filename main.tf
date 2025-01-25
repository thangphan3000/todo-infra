provider "aws" {
  region = var.region
}

### Resource ###
resource "aws_key_pair" "mysql_key_pair" {
  key_name   = "mysql_key_pair"
  public_key = file(var.key_pair_path)
}

### Modules ###
module "security" {
  source = "./modules/security"
}

module "compute" {
  source             = "./modules/compute"
  key_name           = aws_key_pair.mysql_key_pair.key_name
  image_id           = var.image_id
  instance_type      = var.instance_types[var.environment]
  security_group_ids = [module.security.public_security_group_id]
}
