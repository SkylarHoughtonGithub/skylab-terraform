variable "bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name."
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of a customer-managed KMS key used for SSE-KMS. Required; raw AES256 (SSE-S3) is flagged HIGH by Trivy (AWS-0132)."
}

variable "versioning_enabled" {
  type        = bool
  description = "Whether object versioning is enabled on the bucket."
  default     = true
}

variable "lifecycle_rules" {
  type = list(object({
    id     = string
    status = string
    filter = any
    transition = optional(list(object({
      days          = optional(number)
      date          = optional(string)
      storage_class = string
    })), [])
    expiration = optional(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days           = number
      newer_noncurrent_versions = optional(number)
    }))
    abort_incomplete_multipart_upload_days = optional(number)
  }))
  description = "Optional list of lifecycle rules. Each item mirrors the aws_s3_bucket_lifecycle_configuration rule shape."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the bucket."
  default     = {}
}
