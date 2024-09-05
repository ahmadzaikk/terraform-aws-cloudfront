resource "aws_s3_bucket" "this" {
  count = var.origin_type == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  tags = var.tags
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.origin_type == "s3" ? aws_s3_bucket.this.bucket_regional_domain_name : var.alb_domain_name
    origin_id   = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this.bucket}" : "ALB-${var.alb_domain_name}"

    s3_origin_config {
      origin_access_identity = var.origin_type == "s3" ? aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path : null
    }

    custom_origin_config {
      origin_protocol_policy = var.origin_type == "alb" ? "http-only" : null
      http_port              = var.origin_type == "alb" ? 80 : null
      https_port             = var.origin_type == "alb" ? 443 : null
      origin_ssl_protocols   = var.origin_type == "alb" ? ["TLSv1.2"] : null
    }
  }

  # Additional CloudFront distribution settings here
}

resource "aws_cloudfront_origin_access_identity" "this" {
  count = var.origin_type == "s3" ? 1 : 0

  comment = "Origin Access Identity for S3 Bucket"
}

resource "aws_s3_bucket_policy" "this" {
  count = var.origin_type == "s3" ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  count = var.origin_type == "s3" ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}
