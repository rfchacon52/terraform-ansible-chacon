#-----------------
# General Variables
#-----------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "am_id" {
  description = "AMI to use"
  type        = string
  default     = "ami-0c5ebd68eb61ff68d"
}
variable "instance_type" {
  description = "Instance type "
  type        = string
  default     = "t2.small"
}
variable "cluster_name" {
 description = "Cluster name"
  type        = string
  default     = "EKS-DEV"
}

