variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "image_id" {
  type     = string
  nullable = false
}

variable "instance_type" {
  type     = string
  nullable = false
}

variable "key_name" {
  type     = string
  nullable = false
}

variable "security_group_ids" {
  type     = list(string)
  nullable = false
}
