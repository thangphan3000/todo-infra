output "bastion_sg_id" {
  value = aws_security_group.mgmt_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "db_master_id" {
  value = aws_security_group.db_master_sg.id
}
