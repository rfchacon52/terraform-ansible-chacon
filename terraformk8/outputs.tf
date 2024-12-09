output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.ek.cluster_id
}
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.ek.cluster_endpoint
}
output "region" {
  description = "AWS region"
  value       = var.aws_region
}
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}
