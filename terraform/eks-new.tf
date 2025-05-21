#----------------------------
# eks_blueprints_addons 
#---------------------------
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.21.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

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

   enable_aws_load_balancer_controller    = true
 # enable_cluster_proportional_autoscaler = true
#  enable_karpenter                       = true
 # enable_kube_prometheus_stack           = true
 # enable_metrics_server                  = true
#  enable_external_dns                    = true
#  enable_cert_manager                    = true
#  cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
}

#----------------------------
# EKS 
#---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name = var.cluster_name 
  cluster_version = "1.31"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true


  vpc_id      = module.vpc.vpc_id
  subnet_ids  =  module.vpc.private_subnets

 eks_managed_node_group_defaults = {
    disk_size = 50
  }

 eks_managed_node_groups = {
    node_grp1 = {
      instance_types = ["t2.small"]
      ami_type       = "AL2_x86_64"
      min_size = 1
      max_size = 3 
      desired_size = 2
    vpc_security_group_ids = concat (
    [aws_security_group.eks_worker_node_ingress_argocd_http.id,aws_security_group.worker_group_mgmt_two.id,aws_security_group.worker_group_mgmt_one.id,aws_security_group.all_worker_mgmt.id]
   )
    } 
  tags = {
    Environment = "Dev"
  }
}

}