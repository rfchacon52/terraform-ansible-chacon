output "private_key" {
  value     = tls_private_key.transfer_key.private_key_pem
  sensitive = true
}

output "transfer_server_endpoint" {
  value = aws_transfer_server.transfer_server.endpoint
}

output "main_bucket_name" {
  value = aws_s3_bucket.main_bucket.bucket
}

