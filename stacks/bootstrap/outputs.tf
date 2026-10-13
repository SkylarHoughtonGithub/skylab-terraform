output "state_bucket_name" {
  value       = aws_s3_bucket.state.id
  description = "Name of the Terraform state bucket. Reference in other stacks' backend config."
}

output "region" {
  value       = var.region
  description = "AWS region of the state bucket."
}

output "state_kms_key_arn" {
  value       = aws_kms_key.state.arn
  description = "ARN of the KMS CMK that encrypts the state bucket. Reusable for Loki/Tempo/TechDocs buckets in follow-up stacks."
}
