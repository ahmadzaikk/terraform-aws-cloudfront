variable "origin_type" {
  description = "Type of origin (s3 or alb)"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "alb_domain_name" {
  description = "Domain name of the ALB (optional if origin is s3)"
  type        = string
  default     = "" # Default to empty if not used
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront (optional if origin is s3)"
  type        = string
  default     = "" # Default to empty if not used
}



variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}
