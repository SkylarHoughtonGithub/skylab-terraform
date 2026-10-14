variable "region" {
  type        = string
  description = "AWS region for the qdevice ECR repo, KMS key, and ECS service."
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC in which the qdevice Fargate task runs."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets the qdevice task ENIs land in. Must have outbound access to ECR, CloudWatch Logs, and the Proxmox cluster the qdevice is voting for."
}

variable "image_tag" {
  type        = string
  description = "Tag of the qdevice image in the ECR repo. Defaults to `scaffold`, which is what the stub Dockerfile is intended to be pushed as while the real qdevice port is pending."
  default     = "scaffold"
}

variable "desired_count" {
  type        = number
  description = "Running tasks. One qdevice vote arbiter is enough; keep at 1 unless the Proxmox cluster quorum config says otherwise."
  default     = 1
}
