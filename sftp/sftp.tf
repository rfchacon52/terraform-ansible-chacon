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
      "Resource" = "*"
    },
      {
        Effect   = "Allow"
        Action   = [
            "s3:ListBucket",
            "s3:GetBucketLocation",
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

# Create an SSH key pair (AWS Managed)
resource "aws_key_pair" "transfer_key" {
  key_name   = "transfer-server-key"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI81EOwYm7z2fiXrEFWeCDU16V2g3MbJFt35DhntyeQEIpuExmYxwdZ1i3rbldDb6Y7zbKlTMj25WwOFCz+kHQlKCtqggGKMxG2qgg+CjG5CPReYA3T8gRAsaGnM+xwlLwjPVY+edKuRzZpFdAPe44Kj3cuwKguVH/MqtvcSfbZBo8BAChm3P2koYXW01kWCIbfy778T0ADzCSGzqC5UwEmhZ6oHN6QXzDDqWSDTWDYgBagGd/8vgDtr9BaDUlFw8YJ9Q21bMIuCzFOef5aac1Vr0copa3zolVvznt86YzAi9LKCACSfVRRzRrS3VOSAS8I0QOynE7VsxlhqT0p2Sn"
  tags = {
    Name        = "transfer-key"
    Environment = "dev"
  }
}

resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED" # Or "API_GATEWAY", "AWS_DIRECTORY_SERVICE"
  protocols = ["SFTP"] # Add other protocols as needed: "FTP", "FTPS"
  domain    = "S3"     # Specify S3 as the backing storage
 # host_key = var.sftp_host_private_key
host_key  = <<-EOF
-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
  EOF
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
 aws_key_pair" "transfer_key" 
 ssh_public_keys {
    public_key_body = aws_key_pair.transfer_key.public_key
  } 
  
  tags = {
    Name        = "sftp-user"
    Environment = "dev"
  }
}
#Generate SSH key 
/* resource "aws_transfer_ssh_key" "ssh_key" {
  server_id = aws_transfer_server.transfer_server.id
  user_name = "sftp-user" 
  body = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI81EOwYm7z2fiXrEFWeCDU16V2g3MbJFt35DhntyeQEIpuExmYxwdZ1i3rbldDb6Y7zbKlTMj25WwOFCz+kHQlKCtqggGKMxG2qgg+CjG5CPReYA3T8gRAsaGnM+xwlLwjPVY+edKuRzZpFdAPe44Kj3cuwKguVH/MqtvcSfbZBo8BAChm3P2koYXW01kWCIbfy778T0ADzCSGzqC5UwEmhZ6oHN6QXzDDqWSDTWDYgBagGd/8vgDtr9BaDUlFw8YJ9Q21bMIuCzFOef5aac1Vr0copa3zolVvznt86YzAi9LKCACSfVRRzRrS3VOSAS8I0QOynE7VsxlhqT0p2Sn" 
  }
*/
