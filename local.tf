locals {
  cache_policy_id = (
    var.cache_policy_type == "cache-optimized" ? 
    data.aws_cloudfront_cache_policy.cache_optimized.id : 
    data.aws_cloudfront_cache_policy.caching_disabled.id
  )
}
