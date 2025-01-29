terraform {
  backend "s3" {
    bucket         = "non-prod-todo-terraform-state"
    key            = "terraform"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock-state"
  }
}
