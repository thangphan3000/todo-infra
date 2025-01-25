variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
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
  type = string
  default = "./key-pair/operation-key.pub"
}
