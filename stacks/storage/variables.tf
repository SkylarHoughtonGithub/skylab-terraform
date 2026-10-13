variable "region" {
  type        = string
  description = "AWS region for the storage buckets and their KMS key."
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  type        = string
  description = "Prefix for every bucket name in this stack. Combined with a per-bucket suffix (`-loki`, `-tempo`, `-techdocs`) to form globally-unique names."
}
