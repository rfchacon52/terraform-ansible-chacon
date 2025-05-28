# ------------------------------------
# Kubernetes Provider Configuration
# ------------------------------------

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
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

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
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
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
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
