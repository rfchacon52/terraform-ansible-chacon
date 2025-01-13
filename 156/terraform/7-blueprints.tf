module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.19.0" #ensure to update this to the latest/desired version

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
  enable_aws_cloudwatch_metrics          = true
#  enable_cluster_proportional_autoscaler = true
#  enable_karpenter                       = true
#  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
#  cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/*"]

  tags = {
    Environment = "dev"
  }
    
}

#---------------------------------------------
resource "kubernetes_storage_class" "this" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  allow_volume_expansion = true
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
  }
}

#---------------------------------------------

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name    = var.cluster_name 
  cluster_version = var.cluster_version 
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true


  vpc_id      = module.vpc.vpc_id
  subnet_ids  =  module.vpc.private_subnets

 eks_managed_node_group_defaults = {
    disk_size = 60
  }

 eks_managed_node_groups = {
    node_grp1 = {
      instance_types = ["t3.medium"]
      min_size = 1
      max_size = 3 
      desired_size = 2
    }
   }
  tags = {
    Environment = "Dev"
  }
}


