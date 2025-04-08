
# -----------------------------------------------------------------------------
# S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "sftp-home-bucket"  {
  bucket = "sftp-home-bucket" 
  }

resource "aws_s3_bucket_acl" "sftp-home-bucket" {
  bucket = aws_s3_bucket.sftp-home-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning-sftp-home-bucket" {
  bucket = aws_s3_bucket.sftp-home-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "sftp-home-block" {
  bucket                  = aws_s3_bucket.sftp-home-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
