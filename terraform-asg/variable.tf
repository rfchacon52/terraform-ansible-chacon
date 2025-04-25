# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1" # Change this to your desired region
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c55b956cb0f8556a" # Change this to a valid AMI for your region
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

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

