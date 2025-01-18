################################################################################
# Root module calls supporting modules. All variables and providers defined in
# variables.tf amd provider.tf  
################################################################################

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source = "./modules/vpc"
}

################################################################################
# EKS Cluster Module
################################################################################
module "eks" {
  source = "./modules/eks-cluster"
}

################################################################################
# AWS ALB Controller
################################################################################
module "aws_alb_controller" {
  source = "./modules/aws-alb-controller"

  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}
