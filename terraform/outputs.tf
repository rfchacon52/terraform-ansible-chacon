# outputs.tf

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "kubeconfig" {
  description = "The kubeconfig for connecting to the cluster"
  value       = module.eks.kubeconfig
  sensitive   = true # Mark as sensitive as it contains credentials
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the cluster"
  value       = module.eks.oidc_provider_arn
}

output "node_group_security_group_id" {
  description = "The ID of the security group attached to the worker nodes"
  value       = aws_security_group.eks_node_group.id
}
