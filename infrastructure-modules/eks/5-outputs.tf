output "eks_name" {
  value = "dev-demo" 
}

output "openid_provider_arn" {
  value = aws_iam_openid_connect_provider.this[0].arn
}
