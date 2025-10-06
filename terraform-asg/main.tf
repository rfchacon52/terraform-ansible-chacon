# -----------------------------------------------------------------------------
# 2. Security Groups
# -----------------------------------------------------------------------------

# SG for the BASTION HOST (Allows SSH from your IP)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow SSH from the Internet to the Bastion Host"

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
resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow SSH from Bastion SG only"

  # INGRESS: Allow SSH from the Bastion Security Group (Source = Bastion's SG ID)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Source: Bastion SG
  }

  # EGRESS: Allow all outbound traffic (will use NAT Gateway for internet access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------------
# 3. Bastion Host (Sits in Public Subnet)
# -----------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami             = var.ami_id 
  instance_type   = var.instance_type 
  key_name        = var.ssh_key
  # Launch into the first public subnet
  subnet_id       = element(module.vpc.public_subnets, 0)
  # Must associate public IP to be accessible
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  tags = {
    Name = "Bastion-Host"
  }
}

# -----------------------------------------------------------------------------
# 4. Private EC2 Instances (Sits in Private Subnets)
# -----------------------------------------------------------------------------
resource "aws_instance" "appserver" {
  count         = 2
  ami             = var.ami_id 
  instance_type   = var.instance_type 
  key_name        = var.ssh_key
  
  # Launch into the private subnets, cycling through the list
  subnet_id     = element(module.vpc.private_subnets, count.index)
  
  # DO NOT associate a public IP address
  associate_public_ip_address = false 
  
  # Use the private EC2 security group
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]

  tags = {
    Name     = "Private-AppServer-${count.index + 1}"
    ec2_type = "nginx"
  }
}

# -----------------------------------------------------------------------------
# 5. Outputs for Connection
# -----------------------------------------------------------------------------
output "bastion_public_ip" {
  description = "The public IP needed to SSH to the Bastion host."
  value       = aws_instance.bastion.public_ip
}

output "private_instance_ips" {
  description = "The private IPs you will access via the Bastion."
  value       = aws_instance.appserver[*].private_ip
}
