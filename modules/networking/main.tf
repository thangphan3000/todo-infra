provider "aws" {
  region = var.region
}

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}
