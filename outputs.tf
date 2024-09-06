variable "origin_type" {
  description = "The type of origin for the CloudFront distribution. Can be 's3' or 'alb'."
  type        = string
  default     = "s3" # Change to "alb" to use ALB as origin
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  type        = string
}

variable "default_root_object" {
  description = "The default root object for the CloudFront distribution."
  type        = string
}
