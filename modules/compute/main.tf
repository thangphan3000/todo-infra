locals {
  eks_node_security_groups = compact(concat([var.eks_node_sg_id, aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]))
  eks_pod_identity_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["pods.eks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
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
  name = "${var.environment}-eksClusterAdmin"

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
  name     = "${var.environment}-cluster"
  version  = var.eks_cluster_config.kubernetes_version
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
  name = "${var.environment}-eksEC2NodeGroup"

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

resource "aws_launch_template" "eks_node_launch_template" {
  name_prefix            = var.eks_node_launch_template.name_prefix
  key_name               = var.key_name
  vpc_security_group_ids = local.eks_node_security_groups

  block_device_mappings {
    device_name = var.eks_node_launch_template.block_device_mappings.device_name

    ebs {
      volume_size = var.eks_node_launch_template.block_device_mappings.ebs.volume_size
      volume_type = var.eks_node_launch_template.block_device_mappings.ebs.volume_type
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Environment = "${var.environment}"
    }
  }
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = var.eks_cluster_config.kubernetes_version
  node_group_name = var.eks_cluster_config.node_group.name
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids
  capacity_type   = var.eks_cluster_config.node_group.capacity_type
  instance_types  = [var.eks_cluster_config.node_group.instance_type]

  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.eks_cluster_config.node_group.scaling_config.desired_size
    max_size     = var.eks_cluster_config.node_group.scaling_config.max_size
    min_size     = var.eks_cluster_config.node_group.scaling_config.min_size
  }

  update_config {
    max_unavailable = var.eks_cluster_config.node_group.max_unavailable_node
  }

  labels = {
    role = var.eks_cluster_config.node_group.name
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

resource "aws_eks_addon" "eks_addon_pod_identity" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "eks-pod-identity-agent"
  addon_version            = "v1.3.4-eksbuild.1"
  service_account_role_arn = aws_iam_role.pod_identity.arn
}

resource "aws_iam_role" "pod_identity" {
  name               = "${var.environment}-eksPodIdentity"
  assume_role_policy = local.eks_pod_identity_assume_role_policy
}

resource "aws_iam_role" "lbc" {
  name               = "${var.environment}-eksPodIdentityLoadBalancerController"
  assume_role_policy = local.eks_pod_identity_assume_role_policy
}

resource "aws_iam_policy" "lbc" {
  policy = file("${path.module}/iam/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "lbc" {
  policy_arn = aws_iam_policy.lbc.arn
  role       = aws_iam_role.lbc.name
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc.arn
}

resource "helm_release" "lbc" {
  name       = "eks"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }
}

resource "helm_release" "ingress_nginx" {
  name = "nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true
  version          = "4.10.1"

  values = [file("${path.module}/values/nginx-ingress.yaml")]

  depends_on = [helm_release.lbc]
}

resource "aws_iam_role" "cert_manager" {
  name               = "${var.environment}-eksPodIdentityRoute53"
  assume_role_policy = local.eks_pod_identity_assume_role_policy
}

resource "aws_iam_policy" "cert_manager" {
  name   = "AWSRoute53ForCertManager"
  policy = file("${path.module}/iam/AWSRoute53ForCertManager.json")
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  policy_arn = aws_iam_policy.cert_manager.arn
  role       = aws_iam_role.cert_manager.name
}

resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  role_arn        = aws_iam_role.cert_manager.arn
}

resource "aws_iam_role" "csi_driver" {
  name               = "${var.environment}-eksPodIdentityCSIDriver"
  assume_role_policy = local.eks_pod_identity_assume_role_policy
}

resource "aws_iam_policy" "csi_driver" {
  name = "${var.environment}-eksSecretsStoreCSIDriver"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.eks_secretsmanager_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "csi_driver" {
  policy_arn = aws_iam_policy.csi_driver.arn
  role       = aws_iam_role.csi_driver.name
}

resource "aws_eks_pod_identity_association" "csi_driver" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "default"
  service_account = "app-secrets"
  role_arn        = aws_iam_role.csi_driver.arn
}

resource "helm_release" "release" {
  for_each         = var.helm_releases
  name             = each.key
  repository       = each.value.release.repository
  chart            = each.value.release.chart
  namespace        = each.value.release.namespace
  version          = each.value.release.version
  create_namespace = each.value.release.create_namespace

  dynamic "set" {
    for_each = each.value.default_values

    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [aws_eks_node_group.node]
}

resource "helm_release" "application" {
  name       = "todo-cozy"
  repository = "https://thangsuperman.github.io/todo-manifests"
  chart      = "todo-cozy"
  namespace  = "default"
  version    = "0.1.1"

  depends_on = [helm_release.ingress_nginx, helm_release.release]
}
