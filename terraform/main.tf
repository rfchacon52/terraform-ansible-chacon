################################################################################
#  Locals 
################################################################################

provider "aws" {
  region = local.region
}

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
  env  = "Dev"

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
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

}

