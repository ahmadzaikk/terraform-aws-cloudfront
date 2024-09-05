output "s3_bucket_id" {
  value     = aws_s3_bucket.this.bucket
  condition = var.origin_type == "s3"
}

output "alb_domain_name" {
  value     = var.alb_domain_name
  condition = var.origin_type == "alb"
}
