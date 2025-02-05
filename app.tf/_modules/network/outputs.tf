output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_private_subnet_ids" {
  value = module.vpc.private_subnets
}
output "vpc_public_subnet_ids" {
  value = module.vpc.public_subnets
}
output "vpc_db_subnet_group_id" {
  value = module.vpc.database_subnet_group
}
output "intra_subnet_ids" {
  value = module.vpc.intra_subnets
}
output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}
