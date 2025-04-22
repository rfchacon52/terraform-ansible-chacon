# create security group to allow ingoing ports

resource "aws_vpc_security_group_ingress_rule" "terra-SG-80" {
  security_group_id = aws_security_group.terra-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}


resource "aws_vpc_security_group_ingress_rule" "terra-SG-22" {
  security_group_id = aws_security_group.terra-SG.id
  cidr_ipv4 = "10.0.0.0/16"
  from_port   = 22 
  ip_protocol = "tcp"
  to_port     = 22 
}

resource "aws_vpc_security_group_egress_rule" "egress-80" {
security_group_id = aws_security_group.terra-SG.id 

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

resource "aws_security_group" "terramino_instance" {
  name = "learn-asg-terramino-instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
#    security_groups = [aws_security_group.terramino_lb.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "terramino_lb" {
  name = "learn-asg-terramino-lb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}
