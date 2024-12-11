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
  default     = "t2.micro"
}
variable "cluster_name" {
 description = "Cluster name"
  type        = string
  default     = "EKS-DEV"
}


variable "release_name" {
  type        = string
  default     = "nginx"
  description = "The name of our release."
}

variable "chart_repository_url" {
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
  description = "The chart repository url."
}

variable "chart_name" {
  type        = string
  default     = "nginx"
  description = "The name of of our chart that we want to install from the repository."
}

variable "chart_version" {
  type        = string
  default     = "13.2.20"
  description = "The version of our chart."
}

variable "namespace" {
  type        = string
  default     = "apps"
  description = "The namespace where our release should be deployed into."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "If it should create the namespace if it doesnt exist."
}

variable "atomic" {
  type        = bool
  default     = false
  description = "If it should wait until release is deployed."
}
