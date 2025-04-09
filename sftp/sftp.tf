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


# Create an SSH key pair (private key will be stored locally by Terraform)
resource "aws_key_pair" "transfer_key" {
  key_name   = "transfer-server-key"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your actual public key path

  tags = {
    Environment = "dev"
  }
}

resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED" # Or "API_GATEWAY", "AWS_DIRECTORY_SERVICE"
  protocols = ["SFTP"] # Add other protocols as needed: "FTP", "FTPS"
  domain    = "S3"     # Specify S3 as the backing storage
#  host_key  = "aws_key_pair.transfer_key.private_key" # Use the generated private key
  tags = {
    Name        = "transfer-server"
    Environment = "dev"
  }
}
# Create a Transfer Server User with SSH key authentication
resource "aws_transfer_user" "transfer_user" {
  server_id = aws_transfer_server.transfer_server.id
  user_name = "transferuser" # Choose a username
  role      = aws_iam_role.transfer_role.arn
  home_directory = "/" # Or a specific path within the S3 bucket

  tags = {
    Name        = "transfer-user"
    Environment = "dev"
  }
}