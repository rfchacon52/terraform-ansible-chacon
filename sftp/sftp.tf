# Create an IAM role for the Transfer Server
resource "aws_iam_role" "transfer_role" {
  name = "transfer-server-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    Name        = "transfer-role"
    Environment = "dev"
  }
}

# Create an IAM policy for the Transfer Server to access S3
resource "aws_iam_policy" "transfer_policy" {
  name        = "transfer-server-policy"
  description = "Policy for AWS Transfer Server to access S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
   {
      Effect = "Allow",
      Action = [
        "cloudwatch:*",
        "logs:*",
        "sns:*",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "oam:ListSinks"
      ],
      "Resource" : "*"
    },
      {
        Effect   = "Allow"
        Action   = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetObjectVersion",
            "s3:GetObjectACL",
            "s3:PutObjectACL"
        ]
        Resource = [
          aws_s3_bucket.transfer_bucket.arn,
          "${aws_s3_bucket.transfer_bucket.arn}/*"
        ]
      },
    ]
  })

  tags = {
    Name        = "transfer-policy"
    Environment = "dev"
  }
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "transfer_role_policy_attachment" {
  role       = aws_iam_role.transfer_role.name
  policy_arn = aws_iam_policy.transfer_policy.arn
}


resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED" # Or "API_GATEWAY", "AWS_DIRECTORY_SERVICE"
  protocols = ["SFTP"] # Add other protocols as needed: "FTP", "FTPS"
  domain    = "S3"     # Specify S3 as the backing storage
  host_key = var.sftp_host_private_key
  tags = {
    Name        = "transfer-server"
    Environment = "dev"
  }
}

# Create a Transfer Server User with SSH key authentication
resource "aws_transfer_user" "transfer_user" {
  server_id = aws_transfer_server.transfer_server.id
  user_name = "sftp-user" # Choose a username
  role      = aws_iam_role.transfer_role.arn
  home_directory = "/" # Or a specific path within the S3 bucket

  tags = {
    Name        = "sftp-user"
    Environment = "dev"
  }
}
#Generate SSH key 
resource "aws_transfer_ssh_key" "ssh_key" {
  server_id = aws_transfer_server.transfer_server.id
  user_name = "sftp-user" 
  body = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI81EOwYm7z2fiXrEFWeCDU16V2g3MbJFt35DhntyeQEIpuExmYxwdZ1i3rbldDb6Y7zbKlTMj25WwOFCz+kHQlKCtqggGKMxG2qgg+CjG5CPReYA3T8gRAsaGnM+xwlLwjPVY+edKuRzZpFdAPe44Kj3cuwKguVH/MqtvcSfbZBo8BAChm3P2koYXW01kWCIbfy778T0ADzCSGzqC5UwEmhZ6oHN6QXzDDqWSDTWDYgBagGd/8vgDtr9BaDUlFw8YJ9Q21bMIuCzFOef5aac1Vr0copa3zolVvznt86YzAi9LKCACSfVRRzRrS3VOSAS8I0QOynE7VsxlhqT0p2Sn" 
  }
