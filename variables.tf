
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "alb_domain_name" {
  description = "The domain name of the ALB"
  type        = string
}

variable "alb_origin_id" {
  description = "The origin ID for the ALB"
  type        = string
}

variable "origin_type" {
  description = "The type of the origin (s3 or alb)"
  type        = string
  default     = "s3"
}

variable "default_root_object" {
  description = "The default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
