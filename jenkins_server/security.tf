resource "aws_security_group" "jenkins_sg1" {
  name        = "jenkins-sg1"
  vpc_id      =  module.vpc.vpc_id 
  description = "Allow SSH from the Internet "

  # INGRESS: Allow SSH from your workstation (REPLACE CIDR)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # *** CHANGE THIS to your actual IP/CIDR (e.g., "73.45.1.2/32") ***
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EGRESS: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG for the PRIVATE INSTANCES (Allows SSH ONLY from the Bastion)
resource "aws_security_group" "jenkins_sg2" {
  name        = "jenkins-sg2"
  vpc_id      = module.vpc.default_vpc_id 
  description = "Allow traffic on port 1099"

  # INGRESS: Allow SSH from the Bastion Security Group (Source = Bastion's SG ID)
  ingress {
    from_port       = 8080 
    to_port         = 8080 
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg1.id] # Source: Bastion SG
  }

  # EGRESS: Allow all outbound traffic (will use NAT Gateway for internet access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

