resource "aws_s3_bucket" "this" {
  count  = var.origin_type == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  tags   = var.tags
}

resource "aws_cloudfront_origin_access_control" "this" {
  count                            = var.origin_type == "s3" ? 1 : 0
  name                             = "${var.s3_bucket_name}-oac"
  description                      = "OAC for S3 bucket ${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                 = "always"
  signing_protocol                 = "sigv4"
}

resource "aws_cloudfront_distribution" "s3" {
  count               = var.origin_type == "s3" ? 1 : 0
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    domain_name = aws_s3_bucket.this[0].bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.this[0].bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
  }

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.this[0].bucket}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-optimized.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_distribution" "alb" {
  count               = var.origin_type != "s3" ? 1 : 0
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    domain_name = var.alb_arn
    origin_id   = "ALB-${var.alb_arn}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "ALB-${var.alb_arn}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-optimized.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}


