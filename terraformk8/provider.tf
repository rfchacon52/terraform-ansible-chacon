# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
terraform {
  required_providers {
   helm = {
      source  = "hashicorp/helm"
      version = ">= 2.14.0"
    }
 kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.18.0"
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



data "aws_eks_cluster" "cluster" {
name = module.eks.name
}
data "aws_eks_cluster_auth" "cluster" {
name = module.eks.name
}
# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
host = data.aws_eks_cluster.cluster.endpoint
cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
token = data.aws_eks_cluster_auth.cluster.token
}


