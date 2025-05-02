# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1" # Change this to your desired region
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c15e602d3d6c6c4a" # Change this to a valid AMI for your region
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "alb_security_group_name" {
  description = "Name of the security group for the ALB"
  type        = string
  default     = "alb-sg"
}

variable "ec2_security_group_name" {
  description = "Name of the security group for the EC2 instances"
  type        = string
  default     = "ec2-sg"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling group"
  type        = number
  default     = 2
}



