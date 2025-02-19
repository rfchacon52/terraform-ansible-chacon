resource "aws_instance" "Bastion" {
  ami  = "ami-0c7af5fe939f2677f"
  instance_type = "t2.micro"
  key_name   = "deployer.key"
  subnet_id  = module.vpc.public_subnets[0]
  tags = {
    Name = "Bastion"
  }
}

