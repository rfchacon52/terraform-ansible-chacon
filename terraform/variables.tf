# variables.tf

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "EKS-blueprintsr" # Customize this
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Customize this
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16" # Customize this
}

variable "allowed_mac_ip" {
  description = "Your local Mac's IP address for SSH and NodePort access"
  type        = string
  default     = "10.0.0.114/32" # IMPORTANT: Replace with your actual public IP if not in VPC
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31" # IMPORTANT: Use a version supported by EKS (e.g., 1.28, 1.29 as of mid-2025)
}
