
# -----------------------------------------------------------------------------
# IAM Role and Policy for SFTP User Access to Home Directory
# -----------------------------------------------------------------------------

resource "aws_iam_role" "sftp_user_role" {
  name = "SFTPUserRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "SFTPUserRole"
    Environment = "Dev"
  }
}

resource "aws_iam_policy" "sftp_user_policy" {
  name        = "SFTPUserPolicy"
  description = "Policy allowing SFTP user access to their home directory"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.chacon-sftp-home-bucket.arn,
          "${aws_s3_bucket.chacon-sftp-home-bucket.arn}/sftp-user-home/*" # Optional: Allow listing within the home directory
        ]
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "sftp-user-home/",
              "sftp-user-home/*" # Optional: Allow listing within the home directory
            ]
          }
        }
      },
      {
        Sid = "AllowReadWrite"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObjectVersion",
          "s3:GetObjectACL",
          "s3:PutObjectACL",
          "s3.PutBucketAcl"
        ]
        Resource = [
          "${aws_s3_bucket.chacon-sftp-home-bucket.arn}/sftp-user-home/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "SFTPUserPolicy"
    Environment = "Dev"
  }
}

resource "aws_iam_role_policy_attachment" "sftp_user_policy_attachment" {
  role       = aws_iam_role.sftp_user_role.name
  policy_arn = aws_iam_policy.sftp_user_policy.arn
}

# -----------------------------------------------------------------------------
# AWS Transfer Family SFTP Server
# -----------------------------------------------------------------------------


resource "aws_transfer_server" "sftp_server" {
  endpoint_type = "PUBLIC"
  protocols     = ["SFTP"]
}


# -----------------------------------------------------------------------------
# SFTP User Configuration
# -----------------------------------------------------------------------------

resource "aws_transfer_user" "sftp_user" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = "sftpuser" # Choose your desired username
  role      = aws_iam_role.sftp_user_role.arn
  home_directory = "/${aws_s3_bucket.chacon-sftp-home-bucket.bucket}/sftp-user-home"
  policy         = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowAccessToHomeDir"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = aws_s3_bucket.chacon-sftp-home-bucket.arn
        Condition = {
          StringLike = {
            "s3:prefix" = ["sftp-user-home/"]
          }
        }
      }
    ]
  })

  tags = {
    Name        = "SFTPUser"
    Environment = "Dev"
  }
}


#Generate SSH key 
resource "aws_transfer_ssh_key" "ssh_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.sftp_user.user_name
  body = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI81EOwYm7z2fiXrEFWeCDU16V2g3MbJFt35DhntyeQEIpuExmYxwdZ1i3rbldDb6Y7zbKlTMj25WwOFCz+kHQlKCtqggGKMxG2qgg+CjG5CPReYA3T8gRAsaGnM+xwlLwjPVY+edKuRzZpFdAPe44Kj3cuwKguVH/MqtvcSfbZBo8BAChm3P2koYXW01kWCIbfy778T0ADzCSGzqC5UwEmhZ6oHN6QXzDDqWSDTWDYgBagGd/8vgDtr9BaDUlFw8YJ9Q21bMIuCzFOef5aac1Vr0copa3zolVvznt86YzAi9LKCACSfVRRzRrS3VOSAS8I0QOynE7VsxlhqT0p2Sn" 
  }


# -----------------------------------------------------------------------------
# Route 53 Configuration (Assuming you have a Hosted Zone)
# -----------------------------------------------------------------------------
/*
data "aws_route53_zone" "selected" {
  name         = "your-sftp-domain.com." # Replace with your domain name (with trailing dot)
  private_zone = false                   # Set to true if it's a private hosted zone
}

resource "aws_route53_record" "sftp_endpoint" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "sftp.${data.aws_route53_zone.selected.name}" # e.g., sftp.your-sftp-domain.com
  type    = "CNAME"
  ttl     = 300
  records = [aws_transfer_server.sftp_server.endpoint] # This will be the VPC endpoint
}
*/
