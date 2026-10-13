output "state_bucket_name" {
  value       = aws_s3_bucket.state.id
  description = "Name of the Terraform state bucket. Reference in other stacks' backend config."
}

output "region" {
  value       = var.region
  description = "AWS region of the state bucket."
}
