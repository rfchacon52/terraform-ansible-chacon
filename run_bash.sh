#!/bin/bash
 # 1. Identify the IAM Role Associated with the EC2 Instance
# The error message indicates the IAM role:
# arn:aws:sts::767397937300:assumed-role/standard_nodes-eks-node-group-20250330201915130000000004/i-05fbc242688b6eed8

# 2. Extract the IAM Role Name
# From the ARN, the role name is: standard_nodes-eks-node-group-20250330201915130000000004

ROLE_NAME="standard_nodes-eks-node-group-20250330201915130000000004"

# 3. Retrieve the IAM Role ARN (if needed, in case you don't have it)
# This step is redundant because you have the ARN, but it helps demonstrate how to find it.
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query "Role.Arn" --output text)

echo "Role ARN: $ROLE_ARN"

# 4. Create an IAM Policy that Grants route53:ListHostedZones Permission
# Create a JSON policy document with the necessary permissions.

POLICY_DOCUMENT='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZones",
            "Resource": "*"
        }
    ]
}'

# Create the IAM Policy
POLICY_NAME="Route53ListHostedZonesPolicy"

POLICY_ARN=$(aws iam create-policy --policy-name "$POLICY_NAME" --policy-document "$POLICY_DOCUMENT" --query "Policy.Arn" --output text)

echo "Policy ARN: $POLICY_ARN"


# 5. Attach the IAM Policy to the IAM Role
# Attach the newly created policy to the IAM role.

aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"

echo "Policy $POLICY_ARN attached to role $ROLE_NAME"

# 6. Verify the Policy Attachment (Optional)
# Verify that the policy is attached to the role.

aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query "AttachedPolicies[*].PolicyArn" --output text

# 7. Test the Operation
# After attaching the policy, retry the operation that was failing.

# Example:
# aws route53 list-hosted-zones

# If the error is resolved, you should see the hosted zones listed.




