module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "Bastion"

  instance_type          = "t2.micro"
  key_name               = "deployer.key"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    Name   = "Bastion"
  }
}



