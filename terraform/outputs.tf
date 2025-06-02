# outputs.tf

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the cluster"
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster API."
  value       = module.eks.cluster_endpoint
}

output "aws_load_balancer_controller_irsa_arn" {
  description = "ARN of the IAM Role for Service Account (IRSA) for AWS Load Balancer Controller."
  value       = module.eks_blueprints_addons.aws_load_balancer_controller_irsa_arn
}

output "application_ingress_hostname" {
  description = "Hostname of the AWS Application Load Balancer created by the Ingress resource."
  value = one(kubernetes_ingress_v1.my_application_ingress.status[0].load_balancer[0].ingress[0].hostname)
}

output "application_ingress_ip" {
  description = "IP address of the AWS Application Load Balancer created by the Ingress resource (if applicable)."
  value = try(one(kubernetes_ingress_v1.my_application_ingress.status[0].load_balancer[0].ingress[0].ip), "N/A")
}

