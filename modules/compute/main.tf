provider "aws" {
  region = var.region
}

resource "aws_instance" "mysql-resource" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name        = "Mysql Resource 01"
    Environment = "Development"
  }
}

