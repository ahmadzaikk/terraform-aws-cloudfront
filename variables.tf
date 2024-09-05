variable "origin_type" {
  description = "The type of origin for the CloudFront distribution (s3 or alb)."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = ""
}

variable "alb_domain_name" {
  description = "The domain name of the ALB (used if `origin_type` is `alb`)."
  type        = string
  default     = ""
}

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}
