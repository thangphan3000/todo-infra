provider "aws" {
  region = var.aws_region
}

/*
resource "aws_key_pair" "mysql_key_pair" {
  key_name   = "mysql_key_pair"
  public_key = file(var.key_pair_path)
}
*/

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

## VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

## Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnets_cidr)
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets_cidr)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "trusted_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.trusted_subnets_cidr)
  cidr_block        = element(var.trusted_subnets_cidr, count.index)
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-trusted-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "mgmt_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.mgmt_subnets_cidr)
  cidr_block        = element(var.mgmt_subnets_cidr, count.index)
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-mgmt-subnet"
    Environment = "${var.environment}"
  }
}

## Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# TODO: need to add this nat to AZ in zone A and B -> HA
# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = "${var.environment}"
  }
}

## Route tables – private and public subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private_internet_gateway" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}

## Associate route tables for subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr)
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
