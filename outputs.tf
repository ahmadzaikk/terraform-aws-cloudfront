output "s3_bucket_id" {
  value     = var.origin_type == "s3" ? aws_s3_bucket.this.bucket : null
  sensitive = false
}

output "alb_domain_name" {
  value     = var.origin_type == "alb" ? var.alb_domain_name : null
  sensitive = false
}
