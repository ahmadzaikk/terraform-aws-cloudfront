resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    domain_name = var.origin_type == "s3" ? aws_s3_bucket.this.bucket_regional_domain_name : var.alb_arn
    origin_id   = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this.bucket}" : "ALB-${var.alb_arn}"

    origin_access_control_id = var.origin_type == "s3" ? aws_cloudfront_origin_access_control.this[0].id : null
  }

  default_cache_behavior {
    target_origin_id       = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this.bucket}" : "ALB-${var.alb_arn}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-optimized.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    # Uncomment and configure if needed
    # forwarded_values {
    #   query_string = false
    #   cookies {
    #     forward = "none"
    #   }
    # }
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




# Ensure these are declared correctly in your module
resource "aws_cloudfront_origin_access_control" "this" {
  count                            = var.origin_type == "s3" ? 1 : 0
  name                             = "${var.s3_bucket_name}-oac"
  description                      = "OAC for S3 bucket ${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                 = "always"
  signing_protocol                 = "sigv4"
}

data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}
