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

