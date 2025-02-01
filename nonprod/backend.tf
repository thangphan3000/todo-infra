terraform {
  backend "s3" {
    bucket         = "nonprod-todo-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "nonprod-terraform-lock-state"
  }
}
