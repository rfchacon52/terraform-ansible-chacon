terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
 backend "s3" {
     bucket         = "chacon-backend3"
     key            = "terraform/state"
     region         = "us-east-1"
     use_lockfile   = true
  }
}

provider "aws" {
  region = var.aws_region
}