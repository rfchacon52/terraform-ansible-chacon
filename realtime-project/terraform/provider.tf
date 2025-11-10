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


# The Kubernetes provider relies on the cluster being created first.
# It uses the EKS cluster output to authenticate dynamically.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}