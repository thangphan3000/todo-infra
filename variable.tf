variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "CIDR block for Private Subnet"
}

variable "trusted_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
  description = "CIDR block for Trusted Subnet"
}

variable "mgmt_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.7.0/25", "10.0.7.128/25"]
  description = "CIDR block for Management Subnet"
}

variable "image_id" {
  type        = string
  description = "The id of machine image (AMI) to use for the server."
  nullable    = false
  default     = "ami-0bd55ebedabddc3c0"
}

variable "instance_type" {
  type        = string
  description = "Type of VW"
  nullable    = false
  default     = "t2.micro"
}

variable "instance_types" {
  type        = map(string)
  description = "Instance type based on environment"
  default = {
    "prod" : "t3.micro",
    "dev" : "t2.micro",
  }
}

variable "amis" {
  type = map(string)
  default = {
    "prod" : "ami-0bd55ebedabddc3c0",
    "dev" : "ami-0672fd5b9210aa093",
  }
}

variable "key_pair_path" {
  type    = string
  default = "./key-pair/operation-key.pub"
}
