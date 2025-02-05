resource "aws_kms_key" "kms" {
  description             = "The vault for k8s secret"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.default_tags
}
