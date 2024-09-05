resource "aws_s3_bucket" "this" {
  count = var.origin_type == "s3" ? 1 : 0
  tags   = var.tags
  bucket = var.s3_bucket_name
}

resource "aws_cloudfront_origin_access_identity" "this" {
  count = var.origin_type == "s3" ? 1 : 0

  comment = "Origin Access Identity for S3 Bucket"
}

resource "aws_s3_bucket_policy" "this" {
  count = var.origin_type == "s3" ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  policy = data.aws_iam_policy_document.s3_policy[0].json
}

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

resource "aws_cloudfront_distribution" "this" {
  enabled = true

  origin {
    domain_name = var.origin_type == "s3" ? aws_s3_bucket.this[0].bucket_regional_domain_name : var.alb_domain_name
    origin_id   = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : "ALB-${var.alb_domain_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
    }

    custom_origin_config {
      origin_protocol_policy = "http-only" # or "https-only" based on your needs
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : "ALB-${var.alb_domain_name}"
    viewer_protocol_policy = "allow-all"

    # These are arguments, not blocks
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.origin_type == "alb" ? var.acm_certificate_arn : null
    ssl_support_method  = var.origin_type == "alb" ? "sni-only" : null
  }

  tags = {
    Name = "example-cloudfront-distribution"
  }
}
