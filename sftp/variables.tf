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

variable "sftp_host_private_key" {
  type      = string
  sensitive = true 
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI81EOwYm7z2fiXrEFWeCDU16V2g3MbJFt35DhntyeQEIpuExmYxwdZ1i3rbldDb6Y7zbKlTMj25WwOFCz+kHQlKCtqggGKMxG2qgg+CjG5CPReYA3T8gRAsaGnM+xwlLwjPVY+edKuRzZpFdAPe44Kj3cuwKguVH/MqtvcSfbZBo8BAChm3P2koYXW01kWCIbfy778T0ADzCSGzqC5UwEmhZ6oHN6QXzDDqWSDTWDYgBagGd/8vgDtr9BaDUlFw8YJ9Q21bMIuCzFOef5aac1Vr0copa3zolVvznt86YzAi9LKCACSfVRRzRrS3VOSAS8I0QOynE7VsxlhqT0p2Sn"  
}
variable "sftp_host_public_key" {
  type      = string
  sensitive = true 
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI81EOwYm7z2fiXrEFWeCDU16V2g3MbJFt35DhntyeQEIpuExmYxwdZ1i3rbldDb6Y7zbKlTMj25WwOFCz+kHQlKCtqggGKMxG2qgg+CjG5CPReYA3T8gRAsaGnM+xwlLwjPVY+edKuRzZpFdAPe44Kj3cuwKguVH/MqtvcSfbZBo8BAChm3P2koYXW01kWCIbfy778T0ADzCSGzqC5UwEmhZ6oHN6QXzDDqWSDTWDYgBagGd/8vgDtr9BaDUlFw8YJ9Q21bMIuCzFOef5aac1Vr0copa3zolVvznt86YzAi9LKCACSfVRRzRrS3VOSAS8I0QOynE7VsxlhqT0p2Sn"
}

