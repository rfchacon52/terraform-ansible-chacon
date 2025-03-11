###################################################
# State file 
###################################################

terraform {

required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
   kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

  }

###################################################
# State file 
###################################################

  backend "s3" {
    bucket         = "chacon-backend"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }

}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}


