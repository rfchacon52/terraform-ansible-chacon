resource "aws_instance" "Bastion" {
  
  ami  = "ami-0c7af5fe939f2677f"
  instance_type = "t2.micro"
  key_name   = "deployer.key"
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id, aws_vpc_security_group_ingress_rule.terra-SG-22.id]
  associate_public_ip_address = true
 root_block_device {
   volume_type           = "gp2"
   volume_size           = "20"
   delete_on_termination = true
 }
  subnet_id  = module.vpc.public_subnets[0]
  tags = {
    Name = "Bastion"
  }

user_data = << EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y epel-release  
  sudo yum install -y nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx
  sudo echo "<!DOCTYPE html>" > /tmp/index.html
  sudo echo "<html> >> /tmp/index.html
  sudo echo "<body style="background-color:red;">" >> /tmp/index.html
  sudo echo "<h1>This is host my_hostname </h1>" >> /tmp/index.html
  sudo echo "</body>" >> /tmp/index.html
  sudo echo "</html>" >> /tmp/index.html
  host_name=$(/usr/bin/hostname)
  sed -i -e s/my_hostname/$host_name/g /tmp/index.html
  sudo systemctl stop nginx
  sleep 3
  sudo rm -f /usr/share/testpage/index.html
  sudo cp /tmp/index.html /usr/share/testpage
  sudo systemctl start nginx
EOF
}
