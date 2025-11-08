data "aws_ami" "latest_rhel" {
  most_recent = true
  owners      = ["309956199498"] # Official Red Hat Owner ID

  filter {
    name = "name"
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
    Name = "Jenkins-EIP"
  }
}

# Define the EC2 Instance resource
resource "aws_instance" "Jenkins" {
  # Use the ID retrieved from the data source
  ami           = data.aws_ami.latest_rhel.id
  instance_type = "t2.medium"
  # Specify the existing subnet ID
  subnet_id = module.vpc.public_subnets[1] #
  vpc_security_group_ids = [
    aws_security_group.jenkins_sg1.id,
    aws_security_group.jenkins_sg2.id
  ]

  # Optional: For public access, set to true if the subnet is public
  associate_public_ip_address = true

  # Optional: Add your key pair name for SSH access
  key_name = "jenkins"

  tags = {
    Name = "Jenkins"
    VPC  = "Jenkins-VPC"
  }

}

resource "aws_eip_association" "eip_assoc" {
  # Get the ID of the EIP created in step 1
  allocation_id = aws_eip.my_elastic_ip.id
  # Get the ID of the EC2 instance created in step 2
  instance_id = aws_instance.Jenkins.id
}
