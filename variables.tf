variable "origin_type" {
  description = "Type of origin (s3 or alb)"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "path for the default root"
  type        = string
  default     = "index.html"
}

variable "alb_domain_name" {
  description = "Domain name of the ALB"
  type        = string
  default     = "" # Default to empty if not used
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  type        = string
  default     = "" # Default to empty if not used
}


variable "alb_origin_id" {
  default = "MyALB"
}


variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}
