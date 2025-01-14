module "ebs_csi_driver_irsa" {
      source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
      version = "~> 5.20"

      role_name_prefix = "ebs-csi-driver-"

      attach_ebs_csi_policy = true

      oidc_providers = {
        main = {
          provider_arn               = module.eks_cluster.oidc_provider_arn
          namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
        }
      }

      tags = var.tags
    }



resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

