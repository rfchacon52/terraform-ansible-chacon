output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}
output "region" {
  description = "AWS region"
  value       = var.aws_region
}
