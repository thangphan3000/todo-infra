terraform {
  backend "s3" {
    bucket         = "prod-todo-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "prod-terraform-lock-state"
  }
}
