# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Using a recent version is recommended
      version = "~> 5.0" 
    }
  }
  backend "s3" {
    bucket         = "chacon-backend3"
    key            = "terraform/state"
    region         = "us-east-1"
    use_lockfile   = true
  }
}

provider "aws" {
  region = "us-east-2"
}


# Data source to fetch the latest Amazon Linux 2 AMI ID
# This dynamically retrieves the most recent AMI provided by Amazon
data "aws_ami" "latest_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    # Filter for Amazon Linux 2 (amzn2) HVM x86_64 GP2 image
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Define the EC2 Instance resource
resource "aws_instance" "Jmeter" {
  # Use the ID retrieved from the data source
  ami           = data.aws_ami.latest_amazon_linux_2.id 
  instance_type = "t2.small"
  
  # Specify the existing subnet ID
  subnet_id = "subnet-0c5461fa2c798e56b" 

  # IMPORTANT: You may need to add an existing security group for access (e.g., SSH)
  # vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"] 
  vpc_security_group_ids = [
    aws_security_group.jmeter_sg1.id,
    aws_security_group.jmeter_sg2.id,
  ]
  
  # Optional: For public access, set to true if the subnet is public
   associate_public_ip_address = true 
  
  # Optional: Add your key pair name for SSH access
  key_name = "jenkins" 

  tags = {
    Name = "Jmeter"
    VPC  = "vpc-097140fda45fe3368"
  }
}
