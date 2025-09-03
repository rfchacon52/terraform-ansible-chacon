# Create the IAM role for the Transfer user
resource "aws_iam_role" "transfer_user_role" {
  name = "transfer_user_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Generate an SSH key pair
resource "tls_private_key" "transfer_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create the AWS key pair
resource "aws_key_pair" "transfer_key_pair" {
  key_name   = "transfer-server-key"
  public_key = tls_private_key.transfer_key.public_key_openssh
}

# Generate a random suffix for bucket names
resource "random_string" "suffix" {
  length = 16 
  special = false
  upper = false
}

# IAM policy for the Transfer user to access S3
resource "aws_iam_policy" "transfer_user_policy" {
  name        = "transfer-user-policy"
  description = "Policy for Transfer user to access S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
      ],
        Resource = "${aws_s3_bucket.transfer-bucket.arn}/*" # important
      }, 
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
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectACL",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectACL",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.transfer-bucket.arn}/*" # important
      },
       {
        Effect = "Allow",
        Action = ["s3:ListAllMyBuckets"], #Added to fix error.
        Resource = "arn:aws:s3:::*"
      }
    ]
  })
}

# Create the IAM user for AWS Transfer
resource "aws_iam_user" "transfer_user" {
  name = "sftp-user"
}

# Attach the policy to the user
resource "aws_iam_user_policy_attachment" "transfer_user_policy_attachment" {
  user       = aws_iam_user.transfer_user.name
  policy_arn = aws_iam_policy.transfer_user_policy.arn
}

# Create the AWS Transfer Server
resource "aws_transfer_server" "transfer-server" {
  identity_provider_type = "SERVICE_MANAGED" # Or "API_GATEWAY"
  endpoint_type          = "VPC"

  endpoint_details {
    subnet_ids = module.vpc.private_subnets
    vpc_id = join("", module.vpc.vpc_id) 
  }
  domain                 = "S3" #optional, defaults to S3
  protocols              = ["SFTP"] 
  
  tags = {
    Name = "MyTransferServer"
  }
}


# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "transfer_user_role_policy_attachment" {
  role       = aws_iam_role.transfer_user_role.name
  policy_arn = aws_iam_policy.transfer_user_policy.arn
}

# Create the Transfer user's SSH key configuration
resource "aws_transfer_ssh_key" "transfer_user_key" {
  server_id = aws_transfer_server.transfer-server.id
  user_name = aws_transfer_user.transfer_user.user_name
  body      = tls_private_key.transfer_key.public_key_openssh
}

# Create the Transfer user
resource "aws_transfer_user" "transfer_user" {
  server_id = aws_transfer_server.transfer-server.id
  user_name = "sftp-user"
  home_directory = "/transfer-server-main-bucket-${random_string.suffix.result}/transfer-user" # Use the bucket name
  role           = aws_iam_role.transfer_user_role.arn
#  ssh_key_body = tls_private_key.transfer_key.public_key_openssh # moved to aws_transfer_ssh_key resource
}

