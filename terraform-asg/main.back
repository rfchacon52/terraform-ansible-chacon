
##############################
# Target Group for ALB
##############################
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id # Use the vpc_id from the VPC module
  target_type = "instance"
}

##############################
# Load Balancer
##############################
resource "aws_lb" "application_load_balancer" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets[*] # Use the subnets from the VPC module

  tags = {
    Name = "application-load-balancer"
  }
}

##############################
# AWS LB Listner
##############################
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
} 

##############################
# AWS Launch Template 
##############################
resource "aws_launch_template" "launch_template" {
  name_prefix   = "lt-"
  instance_type = var.instance_type
  key_name   = "terraform-lab-key-pair"
  image_id  = var.ami_id 
    block_device_mappings {
    device_name = "/dev/sda1" # Common root device for many Linux AMIs
    ebs {
      volume_size = 20          # Increase root volume size to 50 GiB
      volume_type = "gp3"
      delete_on_termination = true
    }
  }
 network_interfaces {
  device_index = 0
  associate_public_ip_address = true
  security_groups    = [aws_security_group.ec2_sg.id]
  } 
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-instance-launch-template"
    }
  }
}
##############################
# Auto Scaling Group 
##############################
resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "auto-scaling-group"
 launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
  vpc_zone_identifier       = module.vpc.public_subnets[*] # Use the subnets from the VPC module
  target_group_arns         = [aws_lb_target_group.target_group.arn]
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300 # Important for avoiding premature termination

  tag {
    key                 = "Name"
    value               = "ec2-instance"
    propagate_at_launch = true
  }
}


##############################
# CloudWatch Alarm for CPU Utilization 
##############################
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "CPU-High-Alarm"
  alarm_description   = "Alarm when CPU utilization is greater than 80%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300 # 5 minutes
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  alarm_actions         = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.auto_scaling_group.name
  }
}

##############################
# Auto Scaling Policy 
##############################
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                      = "scale-up-policy"
  scaling_adjustment        = 1
  adjustment_type         = "ChangeInCapacity" # Absolute number of instances
  cooldown                    = 300
  autoscaling_group_name  = aws_autoscaling_group.auto_scaling_group.name
}



