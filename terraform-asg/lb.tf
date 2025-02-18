
# Load Bal
resource "aws_lb" "app-lb" {
    name = "app-lb"
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.alb-sg.id]
    subnets =  [module.vpc.public_subnets[0]]
    # count = length(module.vpc.public_subnets)

  # ...
 # subnet_id = module.vpc.private_subnets[count.index]
}
  

# Target Group for ALB
resource "aws_lb_target_group" "alb-ec2-tg" {
    name = "aws-lb-tg"
    port = "80"
    protocol = "HTTP"
    vpc_id   = module.vpc.vpc_id
     tags = {
        Name = "aws-lb-tg"
     }
}

# AWS LB Listner
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb-ec2-tg.arn
    }
   tags = {
        Name = "alb-listener"
    }
}

# Launch Template
resource "aws_launch_template" "ec2-launch-template" {
    name = "ws-launch-template"

    image_id = "ami-013e83f579886baeb"
    instance_type = "t2.micro"
      
    network_interfaces {
      associate_public_ip_address = false
      security_groups = [aws_security_group.ec2-sg.id]
    }
    
    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "ws-launch-template"
      }
    }
}

resource "aws_autoscaling_group" "ec2-sg" {
  name = "web-server-asg"  
  max_size = 3
  min_size = 1
  desired_capacity = 2
  target_group_arns = [aws_lb_target_group.alb-ec2-tg.arn]
  vpc_zone_identifier = [module.vpc.private_subnets[0]]
  
  launch_template {
    id = aws_launch_template.ec2-launch-template.id
    version = "$Latest"
  }
    health_check_type = "EC2"

}