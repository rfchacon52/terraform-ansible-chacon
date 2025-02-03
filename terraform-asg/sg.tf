# create security group to allow ingoing ports

resource "aws_security_group" "terra_SG" {
  name        = "sec_group"
  description = "security group for the EC2 instance"
  vpc_id   = module.vpc.vpc_id

tags = {
    Name = "terra_SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "terra_SG" {
  security_group_id = aws_security_group.terra_SG.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}





