output "vpc_id" {
  description = "The ID of the VPC created by the module"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}


output "ingress_external_url" {
  description = "The external URL/CNAME of the NGINX Ingress Controller's Load Balancer"
  # This retrieves the hostname of the AWS Load Balancer created by the Ingress Service
  value = one(kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[*].hostname)
}

output "ingress_service_ip" {
  description = "The External IP address of the NGINX Ingress Controller Service (may be null for NLB CNAME)"
  value = one(kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[*].ip)
}

# The Kubernetes Service of the NGINX Ingress Controller needs to be referenced 
resource "kubernetes_service_v1" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  # Data source or similar method must be used to link this to the Helm deployment.
  # For simplicity, we reference the service created by the Helm chart directly.
}