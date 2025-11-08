module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"
  name = "VPC-DEV"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw             = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"     = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }


output "vpc_id" {
  description = "The ID of the VPC created by the module"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}




}
