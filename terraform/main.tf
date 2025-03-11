################################################################################
# kubeconfig 
################################################################################
module "eks-kubeconfig" {
  source     = "hyperbadger/eks-kubeconfig/aws"
  version    = "2.0.0"
  depends_on = [module.eks]
  cluster_name =  module.eks.cluster_name
  }

resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig_${local.name}"
}


################################################################################
# Locals
################################################################################
locals {
  name              = "EKS-blueprints"
  cluster_version   = "1.31"
  region            = "us-east-1" 
  node_group_name   = "managed-ondemand"
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.5"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa = true


cluster_compute_config = {
enabled = false
}

 enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]
      disk_size = 50
      subnet_ids   = module.vpc.private_subnets
      max_size     = 3
      desired_size = 2
      min_size     = 1
  }
}


}
#data "aws_eks_cluster" "cluster" {
#  name = module.eks.
#}
#data "aws_eks_cluster_auth" "cluster" {
#  name = module.eks.cluster_name
#}
################################################################################
# EKS Blue Prints Addons 
################################################################################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  create_delay_dependencies = [for prof in module.eks.eks_managed_node_groups : prof.node_group_arn]

 eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  # enable_cluster_proportional_autoscaler = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  #enable_external_dns                    = true
  #enable_cert_manager                    = true
 # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
}
 

