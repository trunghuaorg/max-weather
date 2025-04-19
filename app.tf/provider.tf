//init the terraform config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "u58-tf-state"
    key            = "u58-tf.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "u58-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region     = var.aws_region
}

provider "random" {}
