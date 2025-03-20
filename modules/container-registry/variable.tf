variable "project" {
  type     = string
  nullable = false
}

variable "ecr_repositories" {
  type    = list(string)
  default = ["frontend", "backend"]
}

variable "environment" {
  type     = string
  nullable = false
}
