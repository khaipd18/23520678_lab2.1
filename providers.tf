provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab02-1-23520678"
    key            = "lab2/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
}