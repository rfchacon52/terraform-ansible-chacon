resource "aws_internet_gateway" "igw" {
   vpc_id = module.vpc.vpc_id 

  tags = {
    Name = "igw"
  }
}
