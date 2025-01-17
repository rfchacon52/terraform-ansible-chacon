data "aws_eks_cluster" "this" {
  name = var.cluster_name 
 depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name 
 depends_on = [module.eks]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint

  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)

}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.this.endpoint

    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  }
}


