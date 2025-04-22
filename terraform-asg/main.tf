##############################
# Target Group for ALB
##############################
resource "aws_lb_target_group" "alb-ec2-tg" {
    name = "aws-lb-tg"
    port = "80"
    protocol = "HTTP"
    vpc_id   = module.vpc.vpc_id
    tags = {
        Name = "aws-launch-template"
   }
}
##############################
# Load Balancer
##############################
resource "aws_lb" "app-lb" {
    name = "app-lb"
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.alb-sg.id]
    subnets =  module.vpc.public_subnets
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
}
 
##############################
# Launch Templataws_launch_configuration"e
##############################
resource "aws_launch_configuration" "ec2-launch-config" {
    name_prefix = "learn-terraform-aws-asg-"
    image_id  = "ami-0c7af5fe939f2677f"
    instance_type = "t2.micro"
    key_name   = "deployer.key"
    user_data = filebase64("user-data.sh")
    ebs_optimized = true
lifecycle {
    create_before_destroy = true
  }
}

##############################
# Auto Scaling Group 
##############################
resource "aws_autoscaling_group" "aws_auto_group" {
  name      = "aws_auto_group"
  max_size = 3
  min_size = 1
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.ec2-launch-config 
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "HashiCorp Learn ASG - Terramino"
    propagate_at_launch = true
  }
}  

##############################
# Auto Scaling Policy 
##############################
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "terramino_scale_up"
  autoscaling_group_name = aws_autoscaling_group.ec2-sg.name
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
}

##############################
# CloudWatch Metric Alarm 
##############################
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "terramino_scale_up"
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }
} 
  