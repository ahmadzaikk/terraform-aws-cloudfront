

# S3 Bucket Resource
resource "aws_s3_bucket" "this" {
  count  = var.origin_type == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  tags   = var.tags
}

# CloudFront Origin Access Identity for S3
resource "aws_cloudfront_origin_access_identity" "this" {
  count   = var.origin_type == "s3" ? 1 : 0
  comment = "Origin Access Identity for S3 Bucket"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "this" {
  enabled = true

  origin {
    domain_name = var.origin_type == "s3" ? aws_s3_bucket.this[0].bucket_regional_domain_name : var.alb_domain_name
    origin_id   = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : "ALB-${var.alb_domain_name}"

    # S3 Origin Config - only used if origin_type is "s3"
    s3_origin_config {
      origin_access_identity = var.origin_type == "s3" ? aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path : null
    }

    # Custom Origin Config - only used if origin_type is "alb"
    custom_origin_config {
      origin_protocol_policy = var.origin_type == "alb" ? "https-only" : null
      http_port              = var.origin_type == "alb" ? 80 : null
      https_port             = var.origin_type == "alb" ? 443 : null
      origin_ssl_protocols   = var.origin_type == "alb" ? ["TLSv1.2"] : null
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    target_origin_id       = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : "ALB-${var.alb_domain_name}"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Viewer Certificate
  viewer_certificate {
    acm_certificate_arn = var.origin_type == "alb" ? var.acm_certificate_arn : null
    ssl_support_method  = var.origin_type == "alb" ? "sni-only" : null
  }

  # Tags
  tags = {
    Name = "example-cloudfront-distribution"
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.origin_type == "s3" ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  policy = data.aws_iam_policy_document.s3_policy[0].json
}

# IAM Policy Document for S3
data "aws_iam_policy_document" "s3_policy" {
  count = var.origin_type == "s3" ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this[0].arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this[0].iam_arn]
    }
  }
}
