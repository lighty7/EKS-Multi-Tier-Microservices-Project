module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = [var.node_instance_type]
  }

  eks_managed_node_groups = {
    primary = {
      name = "${var.cluster_name}-node-group"

      instance_types = [var.node_instance_type]

      min_size     = var.node_min_capacity
      max_size     = var.node_max_capacity
      desired_size = var.node_desired_capacity

      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      tags = {
        Name = "${var.cluster_name}-node-group"
      }
    }
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "microservices"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-YAML
      - rolearn: ${module.eks.node_iam_role_arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
    YAML
  }
}
