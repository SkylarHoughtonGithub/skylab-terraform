# modules/ecs-service

Minimal reusable Fargate service: one ECS cluster, task definition, service, log group, security group, and the pair of IAM roles ECS needs (execution + task).

Opinionated defaults chosen to pass the repo's Trivy baseline out of the box:

- `readonly_root_filesystem = true` — clears AWS-0030.
- `log_kms_key_arn` wired through to the log group — set it from the caller to clear AWS-0017.
- `enable_exec = false` — avoids AWS-0104 (ECS Exec without audit). Flip on temporarily for debugging only.

Networking is `awsvpc` with an **egress-only** security group. If the service needs inbound traffic the caller adds the ingress rules against `security_group_id`.

## Usage

```hcl
module "qdevice" {
  source = "../../modules/ecs-service"

  name       = "qdevice"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  image_uri  = "${aws_ecr_repository.qdevice.repository_url}:scaffold"

  log_kms_key_arn          = aws_kms_key.qdevice.arn
  readonly_root_filesystem = true

  tags = {
    "skylab.io/service" = "qdevice"
  }
}
```

## Inputs

| Name | Type | Default | Required |
| --- | --- | --- | --- |
| `name` | string | — | yes |
| `vpc_id` | string | — | yes |
| `subnet_ids` | list(string) | — | yes |
| `image_uri` | string | — | yes |
| `cpu` | number | `256` | no |
| `memory` | number | `512` | no |
| `desired_count` | number | `1` | no |
| `environment` | map(string) | `{}` | no |
| `secrets` | list of `{ name, valueFrom }` | `[]` | no |
| `exec_role_additional_policy_arns` | list(string) | `[]` | no |
| `task_role_additional_policy_arns` | list(string) | `[]` | no |
| `log_retention_days` | number | `30` | no |
| `log_kms_key_arn` | string | `null` | no |
| `enable_exec` | bool | `false` | no |
| `readonly_root_filesystem` | bool | `true` | no |
| `tags` | map(string) | `{}` | no |

## Outputs

| Name | Description |
| --- | --- |
| `cluster_arn` | ARN of the ECS cluster. |
| `service_name` | Name of the ECS service. |
| `task_role_arn` | ARN of the task role. |
| `execution_role_arn` | ARN of the task execution role. |
| `security_group_id` | ID of the egress-only task security group. |
| `log_group_name` | Name of the CloudWatch log group. |
