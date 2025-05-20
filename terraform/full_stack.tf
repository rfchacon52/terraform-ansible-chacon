################################################################################
#  Locals 
################################################################################

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name   =  var.cluster_name
  region =  var.region 

  vpc_cidr = var.vpc_cidr 
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    EKSCluster  = local.name
    GithubRepo = "terraform-ansible-chacon"
  }
}


################################################################################
#  VPC
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0" # Specify the version

  name    = local.name 
  cidr    = local.vpc_cidr
  azs     = local.azs 

# Public Subnets
  public_subnets  = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
  private_subnets = [
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw             = true
  one_nat_gateway_per_az = false
  
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

}
###########################################
# EKS Module
###########################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0" # Use the latest version

  cluster_name    = local.name 
  cluster_version = "1.31" # Specify your desired Kubernetes version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  # Use the EKS cluster role created below
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cluster_security_group   = true

  # Managed node group configuration
  eks_managed_node_groups = {
    default = {
      name = "default"
      ami_type       =  var.ami_type
      instance_types = var.instance_types 
      desired_capacity = 2
      min_size  = 1
      max_size  = 4
      # node_group_subnet_ids = module.vpc.private_subnets
      # Ensure nodes use the nodegroup role
      node_group_role_arn = aws_iam_role.eks_nodegroup_role.arn
    }

    }
  }

# Attach the necessary policy to the cluster role
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.21.0" # Use a recent version

  cluster_name    = module.eks.cluster_name
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
#  enable_cluster_proportional_autoscaler = true
#  enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
#  enable_external_dns                    = false
  enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

}