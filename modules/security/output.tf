output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "vpn_server_sg_id" {
  value = aws_security_group.vpn_server_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "eks_node_sg_id" {
  value = aws_security_group.eks_node_sg.id
}
