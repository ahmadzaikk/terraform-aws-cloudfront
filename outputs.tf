output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "s3_bucket_name" {
  value = var.origin_type == "s3" ? aws_s3_bucket.example.bucket : null
}
