output "bastion_public_ip" {
  value = aws_instance.vm["bastion"].public_ip
}

output "eks_node_private_ip" {
  value = data.aws_instances.eks_nodes.private_ips[0]
}

output "vpn_server_public_ip" {
  value = aws_instance.vm["vpn-server"].public_ip
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_ca_certificate" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}
