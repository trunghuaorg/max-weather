variable "vpc_name" {}
variable "vpc_cidr" {}

variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "enable_dns_hostnames" {}

variable "create_database_subnet_group" {}
variable "create_database_subnet_route_table" {}
variable "create_database_internet_gateway_route" {}

variable "enable_flow_log" {}
variable "create_flow_log_cloudwatch_iam_role" {}
variable "create_flow_log_cloudwatch_log_group" {}

variable "default_tags" {}
variable "cluster_name" {

}
