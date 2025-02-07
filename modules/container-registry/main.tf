resource "aws_ecr_repository" "ecr" {
  for_each             = toset(var.ecr_repositories)
  name                 = "${var.environment}-${var.project}-${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name        = "${var.environment}-ecr"
    Environment = "${var.environment}"
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  for_each   = aws_ecr_repository.ecr
  repository = each.value.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
