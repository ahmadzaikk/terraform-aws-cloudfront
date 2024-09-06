# Outputs
output "s3_bucket_id" {
  value = var.origin_type == "s3" ? aws_s3_bucket.this[0].bucket : null
  description = "The ID of the S3 bucket, if the origin is S3."
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this.id
  description = "The ID of the CloudFront distribution."
}
