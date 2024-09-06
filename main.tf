# Define S3 Bucket
resource "aws_s3_bucket" "this" {
  count = var.origin_type == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  tags   = var.tags
}

# Define CloudFront Origin Access Control (OAC) for S3
resource "aws_cloudfront_origin_access_control" "this" {
  count                             = var.origin_type == "s3" ? 1 : 0
  name                              = "${var.s3_bucket_name}-oac"
  description                       = "OAC for S3 bucket ${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Define CloudFront Distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object

  origin {
    count = var.origin_type == "s3" ? 1 : 0
    domain_name = aws_s3_bucket.this[0].bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.this[0].bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
  }

  origin {
    count = var.origin_type == "alb" ? 1 : 0
    domain_name = var.alb_arn
    origin_id   = "ALB-${var.alb_arn}"
    # Add any specific configuration for ALB origin if needed
  }

  default_cache_behavior {
    target_origin_id       = var.origin_type == "s3" ? "S3-${aws_s3_bucket.this[0].bucket}" : "ALB-${var.alb_arn}"
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

# Define S3 Bucket Policy
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
        }
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
