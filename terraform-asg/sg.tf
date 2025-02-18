# create security group to allow ingoing ports

resource "aws_security_group" "terra-SG" {
  name        = "sec_group"
  description = "security group for the EC2 instance"
  vpc_id   = module.vpc.vpc_id

tags = {
    Name = "terra_SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "terra-SG-80" {
  security_group_id = aws_security_group.terra-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}


resource "aws_vpc_security_group_ingress_rule" "terra-SG-22" {
  security_group_id = aws_security_group.terra-SG.id
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


resource "aws_security_group" "alb-sg" {
  name = "alb-sg1"
  description = "Security Group for LB"
  vpc_id   = module.vpc.vpc_id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  tags = {
    Name = "alb-sg1"
    }
}

resource "aws_security_group" "ec2-sg" {
  name = "ec2-sg1"
  description = "Security Group for ec2"
  vpc_id   = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [aws_security_group.alb-sg.id]
  }

 egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  tags = {
    Name = "ec2-sg1"
    }
}

