# stacks/qdevice

External Proxmox corosync vote arbiter (QDevice) run as an ECS Fargate service, so the Proxmox cluster can keep quorum across an even number of nodes without a dedicated third host.

## Migration status

Scaffolding only. The ECR repo, KMS key, log group, roles, and ECS service are real; the container image is a stub (`alpine:3.20` running `sleep infinity`). The port of the legacy `shoutsky-images/images/proxmox-qdevice` logic lands in a follow-up PR. Until then the service is intentionally a no-op — don't point Proxmox at it.

## Resources

- `aws_kms_key` + `aws_kms_alias` (`alias/skylab-qdevice`) — encrypts the CloudWatch log group. Satisfies Trivy AWS-0017.
- `aws_ecr_repository` `skylab-qdevice` — `scan_on_push = true`, `IMMUTABLE` tags, lifecycle policy retaining the last 10 images.
- `module.qdevice` from `modules/ecs-service` — one cluster, task definition, service, egress-only SG, execution + task roles. `readonly_root_filesystem = true` (AWS-0030) and `log_kms_key_arn` wired through.

## Apply order

1. `stacks/bootstrap` — Terraform state bucket must exist first.
2. `stacks/qdevice` — the Terraform here. The ECS task won't be able to pull its image on the first apply because the ECR repo is empty; `desired_count` can be left at `1` and the service will keep retrying until the first image lands.
3. Build + push the first image (see below).

## Build + push the scaffold image by hand

The repo intentionally has **no image-build CI** for qdevice yet; builds are manual while the real logic is pending.

```sh
cd stacks/qdevice

AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/skylab-qdevice

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker build -t "${ECR}:scaffold" .
docker push "${ECR}:scaffold"
```

Tags are `IMMUTABLE`; to roll a new scaffold use a different tag (e.g. `scaffold-2`) and bump `var.image_tag`.

## Variables

| Name | Default | Notes |
| --- | --- | --- |
| `region` | `us-east-1` | Region for ECR, KMS, ECS. |
| `vpc_id` | — | Required. |
| `subnet_ids` | — | Required. Must reach ECR + CloudWatch Logs; eventually the Proxmox nodes too. |
| `image_tag` | `scaffold` | Tag pushed by the manual build above. |
| `desired_count` | `1` | One arbiter is enough. |
