
resource "aws_instance" "by_chaining" {
  for_each = module.vpc.public_subnets 
  instance_type = "t2.micro"
  key_name               = "deployer.key"
  vpc_security_group_ids = [aws_security_group.terra_SG.id]
  subnet_id = each.value.id

  tags = {
    Name = "${each.value.id} instance"
  }
}
