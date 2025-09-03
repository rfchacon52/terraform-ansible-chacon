resource "aws_security_group" "transfer_sg" {
  name_prefix = "transfer-sg-"
  vpc_id      = module.vpc.vpc_id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # **IMPORTANT: Restrict this to your trusted IP ranges**
    description = "Allow SFTP access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "transfer-server-sg"
  }
}

