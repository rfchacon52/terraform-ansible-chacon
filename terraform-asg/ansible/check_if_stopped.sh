#1/bin/bash

aws ec2 describe-instances \
    --region us-east-1 \
    --filters \
        "Name=instance-state-name,Values=stopped" \
        "Name=tag:ec2_type,Values=nginx" \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text
