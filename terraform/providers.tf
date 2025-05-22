###################################################
# Providers file 
###################################################

# versions.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a recent stable version
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23" # Required for deploying Kubernetes resources like service accounts if not using Helm/Blueprints
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11" # For deploying Helm charts like ArgoCD if not via Blueprints
    }
  }
}

provider "aws" {
  region = var.region
}

# The Kubernetes provider configuration needs to wait until the EKS cluster is ready
# and use its output values for authentication.
# This ensures Helm provider also uses the correct cluster context.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# Data source for EKS cluster authentication token for Kubernetes and Helm providers
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}



###################################################
# State file 
###################################################

  backend "s3" {
    bucket         = "chacon-backend3"
    key            = "terraform/state"
    region         = "us-east-1"
    use_lockfile   = true
  }

}


