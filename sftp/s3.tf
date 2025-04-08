
# -----------------------------------------------------------------------------
# S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "sftp_home_bucket"  {
  bucket = "sftp_home_bucket" 
  }

resource "aws_s3_bucket_acl" "sftp_home_bucket" {
  bucket = aws_s3_bucket.sftp_home_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_sftp_home_bucket" {
  bucket = aws_s3_bucket.sftp_home_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "sftp_home_block" {
  bucket                  = aws_s3_bucket.sftp_home_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
