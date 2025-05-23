# ------------------------------------
# Kubernetes Provider Configuration
# ------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.my_eks_cluster_auth.token
}

# Example Kubernetes resource:
# resource "kubernetes_namespace" "my_app_namespace" {
#   metadata {
#     name = "my-application"
#   }
# }

# ------------------------------------
# Helm Provider Configuration
# ------------------------------------
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.my_eks_cluster_auth.token
  }

}

# Example Helm release:
# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx-ingress-controller"
#   namespace  = kubernetes_namespace.my_app_namespace.metadata[0].name # Example dependency
#   version    = "1.4.0"
#
#   values = [
#     file("values/nginx-ingress-values.yaml")
#   ]
# }

# ------------------------------------
# Kubectl Provider Configuration
# ------------------------------------
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.my_eks_cluster_auth.token

}

# Example Kubectl command:
# resource "kubectl_manifest" "create_pod" {
#   yaml = <<EOF
# apiVersion: v1
# kind: Pod
# metadata:
#   name: my-test-pod
# spec:
#   containers:
#   - name: nginx
#     image: nginx
# EOF
# }
