#get the total az in current zone
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}
