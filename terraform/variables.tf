
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
variable "ami_release_version" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "1.31.3-20250103"
}
variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "172.16.0.0/16"
}
variable "region" {
  description = "Default EKS Region"
  type        = string
  default     = "us.east-1"
}

