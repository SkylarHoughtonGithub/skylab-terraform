variable "name" {
  type        = string
  description = "Name used for the ECS cluster, service, task family, log group, security group, and IAM roles. Keep short; AWS enforces per-resource limits (e.g. role names 64 chars)."
}

variable "vpc_id" {
  type        = string
  description = "VPC in which the task security group is created."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs the Fargate task ENIs are placed in. Must be able to reach ECR, CloudWatch Logs, and any downstream service the task talks to."
}

variable "image_uri" {
  type        = string
  description = "Fully-qualified container image URI (e.g. `<account>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>`). Immutable tags recommended."
}

variable "cpu" {
  type        = number
  description = "Fargate task CPU units. Must be a valid Fargate CPU/memory pair."
  default     = 256
}

variable "memory" {
  type        = number
  description = "Fargate task memory (MiB). Must be a valid Fargate CPU/memory pair."
  default     = 512
}

variable "desired_count" {
  type        = number
  description = "Desired number of running tasks."
  default     = 1
}

variable "environment" {
  type        = map(string)
  description = "Plain environment variables injected into the container."
  default     = {}
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "List of ECS task secrets. Each `valueFrom` is a Secrets Manager or SSM Parameter Store ARN; the execution role must have permission to read them."
  default     = []
}

variable "exec_role_additional_policy_arns" {
  type        = list(string)
  description = "Additional managed policy ARNs attached to the task execution role. `AmazonECSTaskExecutionRolePolicy` is always attached."
  default     = []
}

variable "task_role_additional_policy_arns" {
  type        = list(string)
  description = "Managed policy ARNs attached to the task role. The task role has no default policies."
  default     = []
}

variable "log_retention_days" {
  type        = number
  description = "Retention for the task's CloudWatch log group."
  default     = 30
}

variable "log_kms_key_arn" {
  type        = string
  description = "Optional KMS CMK ARN used to encrypt the CloudWatch log group. Setting this clears Trivy AWS-0017."
  default     = null
}

variable "enable_exec" {
  type        = bool
  description = "Enable ECS Exec on the service. Leave off unless debugging; enabling without an audit sink trips Trivy AWS-0104."
  default     = false
}

variable "readonly_root_filesystem" {
  type        = bool
  description = "Set the container's root filesystem read-only. Clears Trivy AWS-0030."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all taggable resources this module creates."
  default     = {}
}
