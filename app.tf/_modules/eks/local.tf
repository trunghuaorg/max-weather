resource "random_integer" "this" {
  min = 10000000
  max = 99999999
}
locals {
  identify = random_integer.this.result
}
