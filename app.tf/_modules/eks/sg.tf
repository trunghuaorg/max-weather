# CLUSTER SECURITY GROUPS


module "cluster-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS node security groups"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Allow pods to communicate with the cluster API Server"
      source_security_group_id = module.node-sg.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_rules             = ["all-all"]
  ingress_ipv6_cidr_blocks = ["2001:db8::/64"]

  tags = {
    Name = "${var.cluster_name}-eks-cluster-sg"
  }
}
module "node-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "${var.cluster_name}-cluster-node-sg"
  description = "EKS node security groups"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [data.aws_vpc.eks.cidr_block]
  ingress_with_self = [
    {
      rule = "all-all"
    },
  ]
  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 1025
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Allow EKS ${var.cluster_name} Control Plane"
      source_security_group_id = module.cluster-sg.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_rules             = ["all-all"]
  ingress_ipv6_cidr_blocks = ["2001:db8::/64"]
  tags = {
    Name                                        = "${var.cluster_name}-eks-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
