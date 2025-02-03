module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "ec2-1"

  instance_type          = "t2.micro"
  key_name               = "deployer.key"
  vpc_security_group_ids = [aws_security_group.terra_SG.id] 
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "ec2-2"

  instance_type          = "t2.micro"
  key_name               = "deployer.key"
  vpc_security_group_ids = [aws_security_group.terra_SG.id] 
  subnet_id              = module.vpc.public_subnets[1]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}
