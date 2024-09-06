# Existing resources...

output "s3_bucket_name" {
  description = "The name of the S3 bucket (only when origin_type is 's3')"
  value       = var.origin_type == "s3" ? aws_s3_bucket.this[0].bucket : null

}

# Output for CloudFront distribution (S3)
output "cloudfront_s3_domain_name" {
  value       = aws_cloudfront_distribution.s3[0].domain_name
  description = "The domain name of the CloudFront distribution for S3"
}


