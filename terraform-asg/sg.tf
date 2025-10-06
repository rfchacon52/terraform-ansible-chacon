# create security group to allow ingoing ports
# Create ALB Security Group
resource "aws_security_group" "ec2_sg" {
  name        = ec2_security_group 
  description = "Allow traffic to ALB"
  vpc_id      = module.vpc.vpc_id
 # --- INGRESS (Inbound Rules) ---
  ingress {
    description = "Allow SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # *** IMPORTANT: Best practice is to restrict this to your IP or a known bastion IP ***
    cidr_blocks = ["10.0.2.161/32"] 
  }
  # Optional: Allow HTTP access
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- EGRESS (Outbound Rules) ---
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = ec2_security_group
  }
}


