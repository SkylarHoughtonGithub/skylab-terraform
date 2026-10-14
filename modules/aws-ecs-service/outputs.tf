output "cluster_arn" {
  value       = aws_ecs_cluster.this.arn
  description = "ARN of the ECS cluster created for this service."
}

output "service_name" {
  value       = aws_ecs_service.this.name
  description = "Name of the ECS service."
}

output "task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "ARN of the task role. Attach additional policies via `task_role_additional_policy_arns`."
}

output "execution_role_arn" {
  value       = aws_iam_role.execution.arn
  description = "ARN of the task execution role."
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "ID of the egress-only task security group. Attach ingress rules in the caller if needed."
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.this.name
  description = "Name of the CloudWatch log group that collects task logs."
}
