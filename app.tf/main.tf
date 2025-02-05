

locals {
  azs        = length(data.aws_availability_zones.available.names)
  account_id = data.aws_caller_identity.current.account_id
}
resource "random_integer" "this" {
  min = 0
  max = 2
}

module "vpc" {
  source                                 = "./_modules/network"
  vpc_cidr                               = var.cidrvpc
  vpc_name                               = var.vpc_name
  enable_nat_gateway                     = var.enable_nat_gateway
  single_nat_gateway                     = var.single_nat_gateway
  enable_dns_hostnames                   = var.enable_dns_hostnames
  create_database_subnet_group           = var.create_database_subnet_group
  create_database_subnet_route_table     = var.create_database_subnet_route_table
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  enable_flow_log                        = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role    = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group   = var.create_flow_log_cloudwatch_log_group
  cluster_name                           = var.eks_config.cluster_name
  default_tags = merge(
    var.default_tags
  )
}

#CREATE THE EKS CLUSTER
module "eks" {
  depends_on = [
    module.vpc
  ]
  source                                         = "./_modules/eks"
  vpc_id                                         = module.vpc.vpc_id
  private_subnet_ids                             = module.vpc.vpc_private_subnet_ids
  intranet_subnet_ids                            = module.vpc.intra_subnet_ids
  env_prefix                                     = var.env_prefix
  cluster_name                                   = var.eks_config.cluster_name
  cluster_version                                = var.eks_config.cluster_version
  min_size                                       = var.eks_config.min_size
  max_size                                       = var.eks_config.max_size
  eks_managed_node_group_defaults_instance_types = var.eks_config.eks_managed_node_group_defaults_instance_types
  manage_aws_auth_configmap                      = var.eks_config.manage_aws_auth_configmap
  instance_types                                 = var.eks_config.instance_types
  endpoint_public_access                         = var.eks_config.endpoint_public_access
  cluster_endpoint_public_access_cidrs           = var.eks_config.cluster_endpoint_public_access_cidrs
  eks_cw_logging                                 = var.eks_config.eks_cw_logging
  default_tags                                   = var.default_tags
}


#CALLING MODULE EC2 TO CREATE THE EC2 INSTANCE 

module "ec2" {
  depends_on = [
    module.vpc
  ]
  source                      = "./_modules/ec2"
  for_each                    = var.bastion_definition
  vpc_id                      = module.vpc.vpc_id
  bastion_instance_class      = each.value.bastion_instance_class
  bastion_name                = each.value.bastion_name
  bastion_public_key          = each.value.bastion_public_key
  trusted_ips                 = toset(each.value.trusted_ips)
  user_data_base64            = each.value.user_data_base64
  bastion_ami                 = each.value.bastion_ami
  associate_public_ip_address = each.value.associate_public_ip_address
  public_subnet_id            = module.vpc.vpc_public_subnet_ids[random_integer.this.result]
  bastion_monitoring          = each.value.bastion_monitoring
  default_tags = merge(
    var.default_tags,
    each.value.ext-tags,
    {
      "ext-env" : terraform.workspace
    }
  )

}
