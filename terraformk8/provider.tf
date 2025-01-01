# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }
   helm = {
      source  = "hashicorp/helm"
      version = ">= 2.14.0"
    }
   kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }
  }
  required_version = ">= 1.5.0"
}

terraform {
  cloud {
    organization = "Chacon_Dev"

    workspaces {
      name = "chacon-ws4"
    }
  }
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


