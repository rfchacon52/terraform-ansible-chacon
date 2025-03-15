###################################################
# State file 
###################################################

terraform {

required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
   kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }

  }

###################################################
# State file 
###################################################

  backend "s3" {
    bucket         = "chacon-backend"
    key            = "terraform/state"
    region         = "us-east-1"
    use_lockfile   = true
  }

}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}


