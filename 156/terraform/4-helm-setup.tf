# Dependent on aws_eks_cluster.name"
#

data "aws_eks_cluster" "this" {
  name = var.cluster_name 

depends_on = [aws_eks_cluster.name]
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name 

depends_on = [aws_eks_cluster.name]
}
provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint

  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)

depends_on = [aws_eks_cluster.name]
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.this.endpoint

    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  }
depends_on = [aws_eks_cluster.name]
}

