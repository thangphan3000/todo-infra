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

resource "aws_db_instance" "master" {
  identifier                = "${var.aws_region}-db-source"
  instance_class            = var.db_instance_class
  engine                    = "mysql"
  engine_version            = var.db_engine_version
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  port                      = var.db_port
  allocated_storage         = var.db_allocated_storage
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  backup_retention_period   = var.db_backup_retention_period
  publicly_accessible       = false
  skip_final_snapshot       = false
  multi_az                  = false
  final_snapshot_identifier = "${var.environment}-${var.db_final_snapshot_identifier}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  vpc_security_group_ids    = [var.db_sg_id]

  tags = {
    Name        = "${var.environment}-db-source"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "replica" {
  identifier          = "${var.aws_region}-db-replica"
  replicate_source_db = aws_db_instance.master.identifier
  instance_class      = var.db_instance_class
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.aws_region}-db-replica"
    Environment = "${var.environment}"
  }
}
