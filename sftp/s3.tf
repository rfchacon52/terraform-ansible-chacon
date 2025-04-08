
# -----------------------------------------------------------------------------
# S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "chacon-sftp-home-bucket"  {
  bucket = "chacon-sftp-home-bucket" 
  }
/*
resource "aws_s3_bucket_acl" "chacon-sftp-home-bucket" {
  bucket = aws_s3_bucket.chacon-sftp-home-bucket.id
  acl    = "private"
}
*/
resource "aws_s3_bucket_versioning" "versioning-chacon-sftp-home-bucket" {
  bucket = aws_s3_bucket.chacon-sftp-home-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "sftp-home-block" {
  bucket                  = aws_s3_bucket.chacon-sftp-home-bucket.id
  block_public_policy     = true
  restrict_public_buckets = true
}
