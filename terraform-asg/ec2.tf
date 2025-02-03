locals {
  web_servers = {
    my-app-00 = {
      machine_type = "t2.micro"
      subnet_id  = module.vpc.public_subnets[0]
    }
    my-app-01 = {
      machine_type = "t2.micro"
      subnet_id  = module.vpc.public_subnets[1]
    }
  }
}


resource "aws_instance" "my_app_eg1" {
  for_each = local.web_servers

  instance_type = each.value.machine_type
  key_name      = "deployer.key"
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.terra_SG.id]

  tags = {
    Name = each.key
  }
}



