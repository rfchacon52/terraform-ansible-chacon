export EKS_CLUSTER_NAME=eksblue
export AWS_REGION=us-east-1
eksctl utils associate-iam-oidc-provider --cluster $EKS_CLUSTER_NAME --region $AWS_REGION --approve
