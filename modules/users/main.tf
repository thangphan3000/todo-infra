resource "aws_iam_user" "elasticsearch_s3_user" {
  name = "${var.environment}-elasticsearch-s3-user"
}

resource "aws_iam_policy_attachment" "s3_access" {
  name       = "elasticsearch-s3-policy-attachment"
  users      = [aws_iam_user.elasticsearch_s3_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_access_key" "elasticsearch_s3_access_key" {
  user = aws_iam_user.elasticsearch_s3_user.name
}
