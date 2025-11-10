# Set environment variables (assuming you have run 'terraform apply')
export CLUSTER_NAME=$(terraform output -raw cluster_name)
export AWS_REGION=$(terraform output -raw aws_region)
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Download the required IAM policy file from AWS
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json # (You must download this file from the official AWS documentation first)

# The EKS module should create the Service Account (aws-load-balancer-controller)
# If it doesn't, you would create it and annotate it with the role ARN:
# kubectl annotate serviceaccount aws-load-balancer-controller -n kube-system \
#     eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/aws-load-balancer-controller-role