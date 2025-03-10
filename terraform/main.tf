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
  node_iam_role_name = module.eks_blueprints_addons.karpenter.node_iam_role_name
  tags = {
    blueprint = local.name
  }
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

  cluster_addons = {
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }

    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    } 
  vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }

  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cloudwatch_log_group              = false
  create_cluster_security_group            = true
  create_node_security_group               = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]

      create_security_group = true 

      subnet_ids   = module.vpc.private_subnets
      max_size     = 3
      desired_size = 2
      min_size     = 1

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      labels = {
        intent = "control-apps"
      }
    }
  }

}

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

  cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  }

module "aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_blueprints_addons.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
}

