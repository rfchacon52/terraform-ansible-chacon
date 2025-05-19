module "eks_blueprints_addons" {

  source  = "aws-ia/eks-blueprints-addons/aws"
  version  = "~> 1.1" 
  
  # Use a compatible version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  
  # Define the addons you want to deploy.  Check the module's documentation
  # for the correct configuration parameters for each addon.
  eks_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
     most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = "arn:aws:iam::767397937300:role/ebs-csi-driver-role" # Replace
    }
  }


  enable_aws_load_balancer_controller    = true
#  enable_cluster_proportional_autoscaler = true
#  enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
#  enable_external_dns                    = false
  enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }

}

# Example IAM role for EBS CSI Driver (if you use it)
resource "aws_iam_role" "ebs-csi-driver-role" {
  name = "ebs-csi-driver-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "sts:OIDCProvider": "oidc.eks.us-east-1.amazonaws.com/id/767397937300" # Replace
          }
        }
      }
    ]
  })
}

#resource "aws_iam_policy_attachment" "ebs_csi_driver_policy_attachment" {
#  role = aws_iam_role.ebs-csi-driver-role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#}


# Example IAM role for EKS Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach policies to the node group role
resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment_2" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment_3" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

