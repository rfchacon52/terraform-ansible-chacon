# Copyright (c) HashiCorp, Inc.

#-----------------------------
data "aws_availability_zones" "available" {
  state = "available"
}
#############################
# VPC Module
#############################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"
  name = "ags-vpc"
  cidr = "10.0.0.0/16"

  azs                     = data.aws_availability_zones.available.names
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets         = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_dns_hostnames    = true
  create_igw              = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  enable_vpn_gateway      = true
}









