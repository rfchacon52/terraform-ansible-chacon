##############################
# Load Balancer
##############################
resource "aws_lb" "app-lb" {
    name = "app-lb"
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.alb-sg.id]
#    count  = length(module.vpc.public_subnets)
   subnets =  [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
#    subnets =  module.vpc.public_subnets[count.index] 
}
  
##############################
# Target Group for ALB
##############################
resource "aws_lb_target_group" "alb-ec2-tg" {
    name = "aws-lb-tg"
    port = "80"
    protocol = "HTTP"
    vpc_id   = module.vpc.vpc_id
    tags = {
        Name = "ws-launch-template"
     }
}

##############################
# AWS LB Listner
##############################
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb-ec2-tg.arn
    }
  tags = {
        Name = "ws-launch-template"
    }
}
 
##############################
# Launch Template
##############################
resource "aws_launch_template" "ec2-launch-template" {
    name = "ws-launch-template"
    image_id  = "ami-0c7af5fe939f2677f"
    instance_type = "t2.micro"
    key_name   = "deployer.key"
    user_data = filebase64("user-data.sh")
    ebs_optimized = true
    update_default_version = true

 block_device_mappings = [
    {
      device_name  = "/dev/sda1"
      no_device    = "false"
      virtual_name = "root"
      ebs = {
        encrypted             = true
        volume_size           = 60 
        delete_on_termination = true
        iops                  = null
        kms_key_id            = null
        snapshot_id           = null
        volume_type           = "standard"
      }
    }
  ]
    network_interfaces {
      associate_public_ip_address = true
      security_groups = [aws_security_group.ec2-sg.id]
    }
    
    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "ws-launch-template"
      }
    }
}

##############################
# Auto Scaling Group 
##############################
resource "aws_autoscaling_group" "ec2-sg" {
  name = "web-server-asg"  
  max_size = 3
  min_size = 1
  desired_capacity = 2
  target_group_arns = [aws_lb_target_group.alb-ec2-tg.arn]
  vpc_zone_identifier = [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]
#  count = length(module.vpc.private_subnets)
#  vpc_zone_identifier = module.vpc.private_subnets[count.index] 
  
  launch_template {
    id = aws_launch_template.ec2-launch-template.id
    version = "$Latest"
  }
    health_check_type = "EC2"
}

##############################
# Auto Scaling Policy 
##############################
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "terramino_scale_down"
  autoscaling_group_name = aws_autoscaling_group.ec2-sg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

##############################
# CloudWatch Metric Alarm 
##############################
resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "terramino_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2-sg.name
  }
}
