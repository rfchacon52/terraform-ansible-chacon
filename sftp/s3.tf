
# -----------------------------------------------------------------------------
# S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "transfer_bucket"  {
  bucket = "transfer-server-main-bucket-${random_string.suffix.result}/${aws_iam_user.transfer_user.name}" # Corrected.  Nested inside main.
    tags = {
    Name        = "chacon-sftp-transfer-bucket"
    Environment = "dev"
   }
  }

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.transfer_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "transfer_bucket_acl" {
  bucket = aws_s3_bucket.transfer_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_versioning" "transfer_bucket_version" {
  bucket = aws_s3_bucket.transfer_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "transfer_bucket_block" {
  bucket = aws_s3_bucket.transfer_bucket.id
  block_public_policy     = true
  restrict_public_buckets = true
}


