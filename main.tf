# S3 Bucket for the origin
resource "aws_s3_bucket" "origin" {
  bucket_prefix = var.s3_bucket_prefix
  acl           = "private"
  tags = var.tags
}

# S3 Bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.origin.arn}/*"
      }
    ]
  })

  tags = var.tags
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.origin_access_identity_comment

  tags = var.tags
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.origin.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "S3-${aws_s3_bucket.origin.id}"
    
    viewer_protocol_policy = var.viewer_protocol_policy

    allowed_methods {
      items          = var.allowed_methods
      cached_methods = var.cached_methods
    }

    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl

    forwarded_values {
      query_string = var.forward_query_string

      headers {
        items    = var.forward_headers
        quantity = length(var.forward_headers)
      }
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [1] : []
    content {
      acm_certificate_arn = var.acm_certificate_arn
      ssl_support_method  = var.ssl_support_method
    }
  }

  price_class = var.price_class
  enabled     = var.enabled

  tags = var.tags
}
