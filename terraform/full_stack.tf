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
    EKS_Blue = {
      name = "EKS-Blue"
      ami_type       =  var.ami_type
      instance_types = ["t2.small"]
      desired_capacity = 2
      min_size  = 1
      max_size  = 4
      create_security_group = true 
      subnet_ids   = module.vpc.private_subnets
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


# Define the addons you want to deploy.  Check the module's documentation
  # for the correct configuration parameters for each addon.
  eks_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
     most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = "arn:aws:iam::767397937300:role/ebs-csi-driver-role" # Replace
    }
  }


 enable_aws_load_balancer_controller    = true
#  enable_cluster_proportional_autoscaler = true
#  enable_karpenter                       = true
#enable_kube_prometheus_stack           = true
enable_metrics_server                  = true
#  enable_external_dns                    = false
enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

}
# Example IAM role for EBS CSI Driver (if you use it)
resource "aws_iam_role" "ebs-csi-driver-role" {
  name = "ebs-csi-driver-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "sts:OIDCProvider": "oidc.eks.us-east-1.amazonaws.com/id/767397937300" # Replace
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ebs_csi_driver_policy_attachment" {
  roles      = [aws_iam_role.ebs-csi-driver-role.name] # <-- THIS IS THE MISSING PART
   name  = aws_iam_role.ebs-csi-driver-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}




# Example IAM role for EKS Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach policies to the node group role
resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment_2" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment_3" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

###########################################
# Apply EKS Cluster Roles 
############################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach the necessary policy to the cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role  = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}