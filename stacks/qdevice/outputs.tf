output "ecr_repository_url" {
  value       = aws_ecr_repository.qdevice.repository_url
  description = "URL of the qdevice ECR repository. Use as the push target when building the real image."
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.qdevice.arn
  description = "ARN of the qdevice ECR repository."
}

output "kms_key_arn" {
  value       = aws_kms_key.qdevice.arn
  description = "ARN of the KMS key encrypting the qdevice log group."
}

output "cluster_arn" {
  value       = module.qdevice.cluster_arn
  description = "ARN of the ECS cluster running qdevice."
}

output "service_name" {
  value       = module.qdevice.service_name
  description = "Name of the qdevice ECS service."
}

output "task_role_arn" {
  value       = module.qdevice.task_role_arn
  description = "ARN of the qdevice task role. Attach downstream policies here once the real service needs AWS access."
}

output "log_group_name" {
  value       = module.qdevice.log_group_name
  description = "CloudWatch log group that collects qdevice container logs."
}
