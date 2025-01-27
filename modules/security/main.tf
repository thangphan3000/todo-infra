provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "mgmt_sg" {
  name        = "mgmt-sg"
  description = "Allow to manage/ debug servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.db_sg.id]
  }

  tags = {
    Name        = "${var.environment}-mgmt-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "db_master_sg" {
  name        = "db-master-sg"
  description = "Database master security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.trusted_subnets_cidr
  }

  tags = {
    Name        = "${var.environment}-db-master-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow to security database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.mgmt_subnets_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = "${var.environment}"
  }
}
