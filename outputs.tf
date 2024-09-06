output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.this[0].bucket
  condition = var.origin_type == "s3"
}
