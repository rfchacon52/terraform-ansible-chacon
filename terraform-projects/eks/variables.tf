
################################################################################
# Default Variables
################################################################################

variable "profile" {
  type    = string
  default = "default"
}

variable "aws_region" {
  type    = string
  default = "us-west-1"
}

################################################################################
# EKS Cluster Variables
################################################################################

variable "cluster_name" {
  type    = string
  default = "EKS-DEV"
}

variable "rolearn" {
  description = "Add admin role to the aws-auth configmap"
}

################################################################################
# ALB Controller Variables
################################################################################

variable "env_name" {
  type    = string
  default = "dev"
}

