variable "origin_type" {
  description = "Type of origin (s3 or alb)"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "alb_domain_name" {
  description = "Domain name of the ALB"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  type        = string
}
