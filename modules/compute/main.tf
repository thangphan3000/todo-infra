provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.mgmt_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "db_source" {
  ami                    = var.db_ami
  instance_type          = var.db_instance_type
  key_name               = var.key_name
  subnet_id              = var.trusted_subnet_ids[0]
  vpc_security_group_ids = [var.db_sg_id, var.db_master_sg_id]

  tags = {
    Name        = "${var.environment}-db-source"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "db_replica" {
  ami                    = var.db_ami
  instance_type          = var.db_instance_type
  key_name               = var.key_name
  subnet_id              = var.trusted_subnet_ids[1]
  vpc_security_group_ids = [var.db_sg_id]

  tags = {
    Name        = "${var.environment}-db-replica"
    Environment = "${var.environment}"
  }
}
