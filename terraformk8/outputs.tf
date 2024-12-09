output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}
output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}
output "region" {
  description = "AWS region"
  value       = var.region
}
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}
