# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#--------------------------------
provider "aws" {
  region = var.aws_region
#  shared_credentials_files = ["/var/lib/jenkins/.aws/credentials"] 
  default_tags {
    tags = {
      site-name = "Chacon-west-1"
    }
  }
}
#-----------------------------
data "aws_availability_zones" "available" {
  state = "available"
}
#----------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "main-vpc"
  version = "5.15.0"
  cidr    = var.vpc_cider_block

  azs                     = data.aws_availability_zones.available.names
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets         = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  enable_vpn_gateway      = true
}
#-----------------------------
resource "aws_launch_template" "terramino" {
  name   = "Chacon-launch-template"
  image_id      = var.am_id
  instance_type = var.instance_type
  key_name      = "deployer-key"
  user_data     = filebase64("user-data.sh")
  vpc_security_group_ids = [aws_security_group.terramino_lb.id]
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      # Size of the EBS volume in GB
      volume_size = 20

      # Type of EBS volume (General Purpose SSD in this case)
      volume_type = "gp2"
    }
  }
  }

#-----------------------------
resource "aws_autoscaling_group" "terramino" {
  name = "Chacon-auto-scaling-group"
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  force_delete     = true 
  launch_template {
    id      = aws_launch_template.terramino.id
    version = "$Latest"
  }
  vpc_zone_identifier = module.vpc.public_subnets
  health_check_type   = "ELB"
  tag {
    key                 = "Name"
    value               = "HashiCorp Learn ASG - Terramino"
    propagate_at_launch = true
  }
}

#-----------------------------
resource "aws_lb" "terramino" {
  name        = "Chacon-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terramino_lb.id]
  subnets            = module.vpc.public_subnets
}

#-----------------------------
resource "aws_lb_target_group" "terramino" {
  name = "Chacon-aws-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
}

#-----------------------------
resource "aws_lb_listener" "terramino" {
  load_balancer_arn = aws_lb.terramino.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terramino.arn
  }
}

#-----------------------------
resource "aws_autoscaling_attachment" "terramino" {
  autoscaling_group_name = aws_autoscaling_group.terramino.id
  lb_target_group_arn    = aws_lb_target_group.terramino.arn
}

