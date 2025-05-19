
variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.31"
}
variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "EKS-blueprints"
}
variable "ami_type" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "AL2_x86_64" 
}

variable "instance_types" {
  description = "Default instance types"
  type        = string
  default     = "t2.small"
}
variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "10.0.0.0/16"
}
variable "region" {
  description = "Default EKS Region"
  type        = string
  default     = "us-east-1"
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 15
} 
