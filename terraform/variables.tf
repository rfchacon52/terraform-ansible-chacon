
variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.32"
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
