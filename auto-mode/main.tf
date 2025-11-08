
################################################################################
#  VPC
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}







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

