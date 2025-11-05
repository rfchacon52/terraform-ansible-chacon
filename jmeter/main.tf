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

data "aws_ami" "latest_rhel" {
  most_recent = true
  owners      = ["309956199498"] # Official Red Hat Owner ID

  filter {
    name   = "name"
    # Targets the latest RHEL 9 (HVM, x86_64) image name pattern
    values = ["RHEL-9*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}


resource "aws_eip" "my_elastic_ip" {
  # Tags are optional but highly recommended for organization
  tags = {
    Name = "Jmeter-EIP"
  }
}



# Define the EC2 Instance resource
resource "aws_instance" "Jmeter" {
  # Use the ID retrieved from the data source
  ami           = data.aws_ami.latest_rhel.id
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


resource "aws_eip_association" "eip_assoc" {
  # Get the ID of the EIP created in step 1
  allocation_id = aws_eip.my_elastic_ip.id
  
  # Get the ID of the EC2 instance created in step 2
  instance_id   = aws_instance.Jmeter.id
}
