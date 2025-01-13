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
}

provider "aws" {
  region = "us-east-1"
}

variable "cluster_name" {
  default = "EKS-DEV"
}
variable "cluster_version" {
  default = "1.31"
}

terraform {
  cloud {
    organization = "Chacon_Dev"

    workspaces {
      name = "chacon-ws4"
    }
  }
}

