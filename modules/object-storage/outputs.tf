output "bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "Name of the bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN of the bucket."
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.this.bucket_domain_name
  description = "Regional domain name of the bucket, for clients that need an endpoint URL."
}
