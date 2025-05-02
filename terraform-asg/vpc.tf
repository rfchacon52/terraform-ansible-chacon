 Latest version of the vpc module as of May 1, 2025
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0" # Use the latest available version

  name = "ASG-VPC"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"] # Replace with your desired AZs in us-east-1
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "dev"
    Project     = "ASG"
  }
}
