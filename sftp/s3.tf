
# -----------------------------------------------------------------------------
# S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "transfer-bucket"  {
  bucket_prefix = "chacon-app"
    tags = {
    Name        = "chacon-sftp-transfer-bucket"
    Environment = "dev"
   }
  }

resource "aws_s3_bucket_ownership_controls" "s3-bucket-acl-ownership" {
  bucket = aws_s3_bucket.transfer-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "transfer-bucket-acl" {
  bucket = aws_s3_bucket.transfer-bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3-bucket-acl-ownership]
}

resource "aws_s3_bucket_versioning" "transfer-bucket-version" {
  bucket = aws_s3_bucket.transfer-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "transfer-bucket-block" {
  bucket = aws_s3_bucket.transfer-bucket.id
  block_public_policy     = true
  restrict_public_buckets = true
}


