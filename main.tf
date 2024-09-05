resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.origin_domain_name
    origin_id   = "S3-${var.origin_id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "S3-${var.origin_id}"
    
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

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = var.ssl_support_method
  }

  price_class = var.price_class
  enabled     = var.enabled
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.origin_access_identity_comment
}
