module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.19.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

eks_addons = {
      kube-proxy = {
        addon_version     = "v1.24.17-eksbuild.4"
        resolve_conflicts = "OVERWRITE"
      }
      coredns = {
        addon_version     = "v1.9.3-eksbuild.10"
        resolve_conflicts = "OVERWRITE"
      }
      aws-ebs-csi-driver = {
        addon_version            = "v1.26.0-eksbuild.1"
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = "arn:aws:iam::${aws-account-id}:role/AmazonEKS_EBS_CSI_DriverRole"
      }
      snapshot-controller = {
        addon_version     = "v6.3.2-eksbuild.1"
        resolve_conflicts = "OVERWRITE"
      }
      vpc-cni = {
        addon_version = "v1.15.5-eksbuild.1"
        preserve      = true
        # terraform not happy with PRESERVE
        resolve_conflicts        = "NONE"
        service_account_role_arn = "arn:aws:iam::${aws-accounts-id}:role/AmazonEKSVPCCNIRole"
        configuration_values = jsonencode({
          env = {
            AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
            ENI_CONFIG_LABEL_DEF               = "failure-domain.beta.kubernetes.io/zone"
          }
        })
      }
  }

  enable_aws_load_balancer_controller    = true
  enable_aws_cloudwatch_metrics          = true
  enable_cluster_proportional_autoscaler = true
  enable_karpenter                       = true
#  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
  cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/*"]

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

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

