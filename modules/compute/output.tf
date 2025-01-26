output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "db_source_private_ip" {
  value = aws_instance.db_source.private_ip
}

output "db_replica_private_ip" {
  value = aws_instance.db_replica.private_ip
}
