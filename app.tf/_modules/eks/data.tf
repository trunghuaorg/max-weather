data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_vpc" "eks" {
  id = var.vpc_id
}
