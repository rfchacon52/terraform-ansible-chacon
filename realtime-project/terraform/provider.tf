terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable "cluster_name" {
  default = "EKS-DEV"
}
variable "cluster_version" {
  default = "1.33"
}

terraform {
  backend "s3" {
    bucket         = "chacon-backend"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}                           
