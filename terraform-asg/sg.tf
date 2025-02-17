# create security group to allow ingoing ports

resource "aws_security_group" "terra_SG" {
  name        = "sec_group"
  description = "security group for the EC2 instance"
  vpc_id   = module.vpc.vpc_id

tags = {
    Name = "terra_SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "terra_SG-80" {
  security_group_id = aws_security_group.terra_SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}


resource "aws_vpc_security_group_ingress_rule" "terra_SG-22" {
  security_group_id = aws_security_group.terra_SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port   = 22 
  ip_protocol = "tcp"
  to_port     = 22 
}

resource "aws_vpc_security_group_egress_rule" "egress-80" {
security_group_id = aws_security_group.terra_SG.id 

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}




