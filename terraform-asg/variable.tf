# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1" # Change this to your desired region
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0dfc569a8686b9320" # Change this to a valid AMI for your region
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key" {
  description = "The key pair name"
  type        = string
  default     = "terraform-lab-key-pair"
}
variable "ec2_security_group_name" {
  description = "Name of the security group for the EC2 instances"
  type        = string
  default     = "ec2-sg"
}
