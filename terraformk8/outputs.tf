output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.ek_al2023.cluster_id
}
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.ek_al2023.cluster_endpoint
}
output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.ek_al2023.kubeconfig
}
output "region" {
  description = "AWS region"
  value       = var.aws_region
}
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}
