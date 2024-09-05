variable "origin_domain_name" {
  description = "The domain name of the origin."
  type        = string
}

variable "origin_id" {
  description = "The unique identifier for the origin."
  type        = string
}

variable "viewer_protocol_policy" {
  description = "The policy that determines which protocols are allowed for viewers."
  type        = string
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  description = "The HTTP methods that are allowed."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "The HTTP methods that are cached."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "min_ttl" {
  description = "The minimum amount of time, in seconds, that an object is cached."
  type        = number
  default     = 3600
}

variable "default_ttl" {
  description = "The default amount of time, in seconds, that an object is cached."
  type        = number
  default     = 86400
}

variable "max_ttl" {
  description = "The maximum amount of time, in seconds, that an object is cached."
  type        = number
  default     = 31536000
}

variable "forward_query_string" {
  description = "Whether query strings are forwarded to the origin."
  type        = bool
  default     = false
}

variable "forward_headers" {
  description = "The headers that are forwarded to the origin."
  type        = list(string)
  default     = ["Host", "Origin"]
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate."
  type        = string
}

variable "ssl_support_method" {
  description = "The SSL/TLS support method."
  type        = string
  default     = "sni-only"
}

variable "price_class" {
  description = "The price class for the distribution."
  type        = string
  default     = "PriceClass_100"
}

variable "enabled" {
  description = "Whether the distribution is enabled."
  type        = bool
  default     = true
}

variable "origin_access_identity_comment" {
  description = "Comment for the origin access identity."
  type        = string
  default     = "example-origin-access-identity"
}
