provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update",
      "sudo dnf install -y mariadb105"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.bastion_private_key
    host        = self.public_ip
  }

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role" "eks" {
  name = "${var.environment}-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.environment}-eks-cluster"
  version  = var.eks_config.kubernetes_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = false

    subnet_ids = var.private_subnet_ids
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.amazon_eks_cluster_policy]
}

resource "aws_iam_role" "nodes" {
  name = "${var.environment}-eks-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = var.eks_config.kubernetes_version
  node_group_name = var.eks_config.node_group.name
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids
  capacity_type   = var.eks_config.node_group.capacity_type
  instance_types  = [var.eks_config.node_group.instance_type]

  scaling_config {
    desired_size = var.eks_config.node_group.scaling_config.desired_size
    max_size     = var.eks_config.node_group.scaling_config.max_size
    min_size     = var.eks_config.node_group.scaling_config.min_size
  }

  update_config {
    max_unavailable = var.eks_config.node_group.max_unavailable_node
  }

  labels = {
    role = var.eks_config.node_group.name
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
