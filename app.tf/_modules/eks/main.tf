resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids     = [module.cluster-sg.security_group_id]
    subnet_ids             = var.intranet_subnet_ids
    endpoint_public_access = var.endpoint_public_access
    public_access_cidrs    = var.cluster_endpoint_public_access_cidrs
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  enabled_cluster_log_types = var.eks_cw_logging

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.kms.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
    aws_kms_key.kms
  ]
}
resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-default-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  # name            = "${var.cluster-name}-worker-node"
  scaling_config {
    desired_size = var.min_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  instance_types = var.instance_types
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy
  ]
  tags = {
    "Name" = "${var.cluster_name}-default-node-group"
    key    = "kubernetes.io/cluster/${var.cluster_name}"
    value  = "owned"
  }
}
