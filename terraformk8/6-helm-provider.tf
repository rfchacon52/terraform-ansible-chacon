provider "helm" {
  kubernetes {
     host = data.aws_eks_cluster.cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
       exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "EKS-DEV"]
      command     = "aws"
    }
  }
}
