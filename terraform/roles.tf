###########################################
# Apply EKS Cluster Roles 
############################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach the necessary policy to the cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role  = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

###########################################
# Apply EBS CSI Driver  
############################################

resource "aws_iam_role" "ebs-csi-driver-role" {
  name = "ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          # CORRECTED: Use Federate to specify the OIDC provider
          # You should get the OIDC provider URL from your EKS cluster output
          # e.g., module.eks.oidc_provider_arn
          Federated = "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/767397937300"
        },
        Action = "sts:AssumeRoleWithWebIdentity", # CORRECTED: This action is for web identity federation
        Condition = {
          StringEquals = {
            # This condition ensures only the specific K8s service account can assume the role
            "oidc.eks.us-east-1.amazonaws.com/id/767397937300:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa" # CORRECTED: Specify the service account
          }
        }
      }
    ]
  })
}
  # This is the standard managed policy for the EBS CSI driver
resource "aws_iam_policy_attachment" "ebs_csi_driver_policy_attachment" {
   name  = aws_iam_role.ebs-csi-driver-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


resource "aws_iam_role" "eks_nodegroup_role" {
      name = "eks-nodegroup-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect    = "Allow"
            Principal = {
              Service = "eks.amazonaws.com"
            }
            Action    = "sts:AssumeRole"
          }
        ]
      })
    }


    resource "aws_iam_role_policy_attachment" "eks_nodegroup_cnipolicy" {
      role       = aws_iam_role.eks_nodegroup_role.name
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    }

    resource "aws_iam_role_policy_attachment" "eks_nodegroup_ec2registry" {
      role       = aws_iam_role.eks_nodegroup_role.name
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }


resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_cni" {
  role  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # AWS managed policy
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_worker" {
  role  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # AWS managed policy
}
