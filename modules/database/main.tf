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

resource "aws_db_instance" "db" {
  db_name                = "todo"
  identifier             = "${var.aws_region}-db-instance"
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "8.0.40"
  username               = var.db_username
  password               = var.db_password
  port                   = 3306
  allocated_storage      = 20
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  backup_retention_period = 7
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.environment}-db"
    Environment = "${var.environment}"
  }
}
