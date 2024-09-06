# Existing resources...

output "s3_bucket_name" {
  description = "The name of the S3 bucket (only when origin_type is 's3')"
  value       = var.origin_type == "s3" ? aws_s3_bucket.this[0].bucket : null
  condition   = var.origin_type == "s3"
}
