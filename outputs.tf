output "cloudfront_domain_name" {
  value = var.origin_type == "s3" ? aws_cloudfront_distribution.s3[0].domain_name : aws_cloudfront_distribution.alb[0].domain_name
}
