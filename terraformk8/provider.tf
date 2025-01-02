# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
terraform {
  required_providers {
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

data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  # token                  = data.aws_eks_cluster_auth.default.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
    command     = "aws"
  }
}
