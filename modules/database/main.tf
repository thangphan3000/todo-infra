provider "aws" {
  region = var.aws_region
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.trusted_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = "${var.environment}"
  }
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier        = "${var.environment}-cluster"
  engine                    = "mysql"
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  db_cluster_instance_class = var.db_instance_class
  database_name             = var.db_name
  port                      = var.db_port
  storage_type              = var.db_storage_type
  allocated_storage         = var.db_allocated_storage
  master_username           = var.db_username
  master_password           = var.db_password
  backup_retention_period   = var.db_backup_retention_period
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.environment}-${var.db_final_snapshot_identifier}-${timestamp()}"
  vpc_security_group_ids    = [var.db_sg_id]

  tags = {
    Name        = "${var.environment}-cluster"
    Environment = "${var.environment}"
  }
}
