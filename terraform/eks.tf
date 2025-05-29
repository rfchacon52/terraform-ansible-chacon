resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/aws-load-balancer-controller-policy.json")
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets # Explicitly define for control plane
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

 cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
    resolve_conflicts = "OVERWRITE" # Important to ensure your settings apply
      most_recent       = true        # Recommended to use the latest patch version
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1" # Recommended for most cases
        }
      })
    } 
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    node-group = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       =  var.ami_type
      instance_types =  ["t2.small"]  
      min_size     = 1
      max_size     = 4
      desired_size = 3
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.20.0" # Latest stable version based on recent activity (v1.20.0 was from Stack Overflow example)

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
 # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  # --- Add-on Configuration: AWS Load Balancer Controller ---

enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
      {
        name  = "enableServiceMutatorWebhook"
        value = "false"
      }
    ]

  }

}

# --- Output the kubeconfig (optional, for convenience) ---
# This output comes from the main 'eks_cluster' module.
#output "kubeconfig" {
#  description = "Generated kubeconfig for the EKS cluster"
#  value       = module.eks.kubeconfig
#  sensitive   = true # Mark as sensitive to prevent showing in plain text in logs








