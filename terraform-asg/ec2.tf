resource "aws_instance" "appserver" {
  count         = 2
  instance_type = var.instance_type
  key_name      = "terraform-lab-key-pair"
  ami           = var.ami_id
  
  # CORRECTION 1: Must be a LIST of security group IDs.
  vpc_security_group_ids = [aws_security_group.ec2_sg.id] 
  
  # CORRECTION 2: Private instances should NOT have public IPs.
  associate_public_ip_address = false 

  # CORRECTION 3: Correctly index the list. Assuming 'private_subnets' is a local list.
  subnet_id = private_subnets[count.index]

  root_block_device {
    volume_type         = "gp2"
    volume_size         = 20 # Volume size should be an integer
    delete_on_termination = true
  }

  tags = {
    Name     = "AppServer-${count.index + 1}"
    ec2_type = "nginx"
  }
}



