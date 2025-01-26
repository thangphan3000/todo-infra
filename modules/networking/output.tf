output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "trusted_subnet_ids" {
  value = [for subnet in aws_subnet.trusted_subnet : subnet.id]

}

output "mgmt_subnet_ids" {
  value = [for subnet in aws_subnet.mgmt_subnet : subnet.id]
}
