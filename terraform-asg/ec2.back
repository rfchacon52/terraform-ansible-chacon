resource "aws_instance" "Bastion" {
  
  ami  = "ami-0c7af5fe939f2677f"
  instance_type = "t2.micro"
  key_name   = "key_name"
  vpc_security_group_ids      = [aws_security_group.terra-SG.id]
  associate_public_ip_address = true
  user_data = file("user-data.sh")
 root_block_device {
   volume_type           = "gp2"
   volume_size           = "20"
   delete_on_termination = true
 }
  subnet_id  = module.vpc.public_subnets[0]
  tags = {
    Name = "Bastion"
  }

}
