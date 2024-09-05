output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket."
  value       = aws_s3_bucket.origin.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.origin.arn
}
