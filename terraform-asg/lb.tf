
# Load Bal
resource "aws_lb" "app-lb" {
    name = "app-lb"
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws.subnet.public_subnet[*]]
  
}

# Target Group for ALB
resource "aws_lb_target_group" "alb_ec2_tg" {
    name = "aws_lb_tg"
    port = "80"
    protocol = "HTTP"
    vpc_id   = module.vpc.vpc_id
     tags = {
        Name = "aws_lb_tg"
     }
}

# AWS LB Listner
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
    }
   tags = {
        Name = "alb_listener"
    }
}

# Launch Template
resource "aws_launch_template" "ec2_launch_template" {
    name = "ws-launch-template"

    image_id = "ami-013e83f579886baeb"
    instance_type = "t2.micro"
      
    network_interfaces {
      associate_public_ip_address = false
      security_groups = [aws_security_group.ec2_sg.id]
    }
    
    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "ws_launch-template"
      }
    }
}

resource "aws_autoscaling_group" "ec2_sg" {
  name = "web-server-asg"  
  max_size = 3
  min_size = 1
  desired_capacity = 2
  target_group_arns = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id
  
  launch_template {
    id = aws_launch_template.ec2_launch_template
  }
}