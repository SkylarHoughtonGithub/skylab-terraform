variable "region" {
  type        = string
  description = "AWS region for the Terraform state bucket."
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name that will hold Terraform state for every stack."
}
