resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.trusted_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "source" {
  identifier                = "${var.aws_region}-db-source"
  instance_class            = var.db_config.instance_class
  engine                    = var.db_config.engine.type
  engine_version            = var.db_config.engine.version
  db_name                   = var.db_config.name
  username                  = var.db_config.username
  password                  = var.db_config.password
  port                      = var.db_config.port
  allocated_storage         = var.db_config.allocated_storage
  backup_retention_period   = var.db_config.backup_retention_period
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  final_snapshot_identifier = "${var.environment}-${var.db_config.final_snapshot_identifier}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  vpc_security_group_ids    = [var.db_sg_id]
  publicly_accessible       = false
  skip_final_snapshot       = false
  multi_az                  = false

  tags = {
    Name        = "${var.environment}-db-source"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "replica" {
  identifier          = "${var.aws_region}-db-replica"
  replicate_source_db = aws_db_instance.source.identifier
  instance_class      = var.db_config.instance_class
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.aws_region}-db-replica"
    Environment = "${var.environment}"
  }
}
