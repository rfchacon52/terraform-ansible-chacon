#----------------------------
# EKS 
#---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id      = module.vpc.vpc_id
  subnet_ids  =  module.vpc.private_subnets

  bootstrap_self_managed_addons = false 
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

 eks_managed_node_group_defaults = {
    instance_types = ["t2.small"]
    ami_type       = "AL2023_x86_64_STANDARD"
    iam_role_additional_policies = {
      ebs_policy                                 = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" #IAM rights needed by CSI driver
      auto_scaling_policy                        = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
      cloudwatch_container_insights_agent_policy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      xray_policy                                = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
    }
  }

 eks_managed_node_groups = {
    node_grp1 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      min_size = 1
      max_size = 10 
      desired_size = 2
    }
 }                                                              

}
