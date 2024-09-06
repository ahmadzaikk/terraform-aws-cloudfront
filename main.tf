# Define S3 Bucket (only if origin_type is s3)
resource "aws_s3_bucket" "this" {
  count  = var.origin_type == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  tags   = var.tags
}

# Define CloudFront Origin Access Control (OAC) for S3 (only if origin_type is s3)
resource "aws_cloudfront_origin_access_control" "this" {
  count                             = var.origin_type == "s3" ? 1 : 0
  name                              = "${var.s3_bucket_name}-oac"
  description                       = "OAC for S3 bucket ${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Cache Policy Data Source
data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}

# Define CloudFront Distribution with dynamic origin (S3 or ALB)
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    domain_name = var.origin_type == "s3" ? aws_s3_bucket.this[0].bucket_regional_domain_name : var.alb_domain_name
    origin_id   = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : var.alb_origin_id
    
    # Only apply origin access control if using S3
    origin_access_control_id = var.origin_type == "s3" ? aws_cloudfront_origin_access_control.this[0].id : null
  }

  default_cache_behavior {
    target_origin_id       = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : var.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-optimized.id
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    # For ALB, allow forwarding headers and cookies if needed
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
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

# Define S3 Bucket Policy (only applied if S3 is the origin)
resource "aws_s3_bucket_policy" "this" {
  count  = var.origin_type == "s3" ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.this[0].arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.this.id}"
          }
        }
      }
    ]
  })
}

# Data for current AWS caller identity
data "aws_caller_identity" "current" {}
