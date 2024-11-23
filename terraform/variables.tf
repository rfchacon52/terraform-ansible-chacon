
#-----------------
# General Variables
#-----------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "vpc_cider_block" {
  description = "vpc cider block"
  type        = string
  default     = "10.0.0.0/16"
}
variable "am_id" {
  description = "AMI to use"
  type        = string
  default     = "ami-0c5ebd68eb61ff68d"
}
variable "instance_type" {
  description = "Instance type "
  type        = string
  default     = "t2.micro"
}
