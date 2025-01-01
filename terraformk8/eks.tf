#----------------------------
# EKS 
#---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true

  cluster_addons = {
    vpc-cni                = {most_recent = true} 
    coredns                = {most_recent = true}
    eks-pod-identity-agent = {most_recent = true}
    kube-proxy             = {most_recent = true}
    aws-ebs-csi-driver     = {most_recent = true}
  }

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
      desired_size = 1
      capacity_type  = "ON_DEMAND"
      
     labels = {
        role = "general"
      }

    }
      # Needed by the aws-ebs-csi-driver
      iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
   }


#manage_aws_auth_configmap = true
#  aws_auth_roles = [
#    {
#      rolearn  = module.eks_admins_iam_role.iam_role_arn
#      username = module.eks_admins_iam_role.iam_role_name
#      groups   = ["system:masters"]
#    },
#  ]

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }

  tags = {
    Environment = "staging"
  }
}