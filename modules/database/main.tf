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
  db_cluster_instance_class = var.db_config.instance_class
  engine                    = var.db_config.engine.type
  engine_version            = var.db_config.engine.version
  database_name             = var.db_config.name
  port                      = var.db_config.port
  storage_type              = var.db_config.storage_type
  allocated_storage         = var.db_config.allocated_storage
  master_username           = var.db_config.username
  master_password           = var.db_config.password
  backup_retention_period   = var.db_config.backup_retention_period
  skip_final_snapshot       = false
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  final_snapshot_identifier = "${var.environment}-${var.db_config.final_snapshot_identifier}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  vpc_security_group_ids    = [var.db_sg_id]

  tags = {
    Name        = "${var.environment}-cluster"
    Environment = "${var.environment}"
  }
}
