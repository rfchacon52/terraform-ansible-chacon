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
   host_key  = <<-EOF
-----BEGIN OPENSSH PRIVATE KEY-----
MIIEogIBAAKCAQEAuUKFa0H4JbxEVSFvh/cGFApQk+hGl0o63rnyZwIfHKw5vIg7
f/+JGxrFx1CKtY0MOrTVTt0og/M7E23JYHlrhIKYaf7W9fpIg2E4MQuTTtelU0Rz
03+FtGXCYxdnQAlIlp1J2X3lac8z68HwXRk8VMXKHeHIaPSBYHtBU+0nuwzJP66p
1CIIBJUkfMljENXKa67KroX0hSy1A9+PfXxJBatLvgjqkPRLIZFwY1enfnwDQVMn
L1raz2NWdz5YKzZvc1X9E4WUKasxmClT/WTC3lMCHtlHb88buB4orATCkQ2BIxVx
W2Z9ANbftthOwqeKjvzs7Ul6nKSiqN+/A0aS4wIDAQABAoIBABA6iI99xuwfUukW
Nbv2YrzsrmRWi6CDKycJqPdnEyyi1afzUysCSpNqQ/sSziPbSD/4SVtQOlVcwEcS
bfqaiFWiTxGx9kiz9Rg1MwPw3KWidGQX8gGMAT1tUJr3mN7eMVKoUqjPw4ICWa0E
Xzb4l/VhIjR9691t1cuK4I0mkD1tWg5DSRQ/2cJzmNP5jlc1H133Jgg5y5KSaEoJ
05MMFLhz4eOKmuxCtY98/tEjFhkoRl6WzWuxm0piKJPqo0ee4xaxHRHwXq6Xqo6O
++U831G/m4FnCEDqh15DsMCqHLyfkwkJoW1f3Ab5Kk48Bc4dRnLFM2IzJULDDLDO
1Mww9zECgYEA6jxu/k2aS9IzFW/TCmfukBqIntKLe+yGV79MsU1/agSB0Xx7m0yO
kMt0PhSIL+Ct1mSJ3JfIIRNUysjAYHVpbaYXEOGQziLf55OXmZrk3lY6/+4/V1Ke
FMkG8yRzB/3mlbLEke0sRTTIalTTw0GCXUBvGNtBWw45Wqun+eKUsNkCgYEAynki
LgVlcaBUcibxKN5CNqgUYSElx0iyuO2ddBCzK/IbmCh4MnePbc76FuDOst4iYpnv
mFZsd3jWXK3E3AHd1L0Mz/djScvUHJGtZi+hiNLghn4T0msaRdE2Mw+rLDSxexXa
xg7J6ybWFReJBk2u2b2DboSE6hhfFmjiFSsjzBsCgYAfOwOJgItMBLCu8QPwZT8X
k5IXqvbSBQ08cdMl6LFOT1+HsNNCN4jioV3UUSR/TbOf3DPNZ6dVUaCCkRWlRsJR
zk1RAOIvudKkq7cQ0egmBNVE/l0PpYJSPyNgE8IKlL3Dw9wVoMvARnNaSgkaBYf+
KvMlG0axf0oCXtS8qosssQKBgHUhWHWZJ5NxNgkHoDGNSm7GE2wROgKser/irljL
pGtC11XR657+bZoPx7ved5UgTnIOLX5KWNtQq2nYGO9RoRwF9diFfAngAag5Wj+o
RGGb5MnJO/xZe0xyeFFXuiWLojTbcsFrIsKHqAdxoxJjdEiAiv0vapjmWnPjXw7x
8vaLAoGAFj2/WPTcCDa3uFh9v+euKL/ixMACdw2XZkYQA5m5DwopHvKWs0U3eUx6
1UnI+cSGrLceN63NEj+YipAzD4tUwA07IDtZZhxMQ1I65iW2unyke8DeDL9pa8dz
O2sc7WF5rEtrQJTxox11BQtGfGw1XPQSKObuKIK6+oBNFBkZ+aI=
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
