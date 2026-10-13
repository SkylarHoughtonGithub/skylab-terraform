# External corosync vote arbiter for the Proxmox cluster, run as an ECS
# Fargate service. This is scaffolding only: ECR repo, KMS-encrypted log
# group, IAM roles, and a Fargate service whose image is a stub. The real
# qdevice port lives in a follow-up PR; until then the ECS task runs
# `sleep infinity` and does nothing useful.

resource "aws_kms_key" "qdevice" {
  description             = "Encrypts the qdevice CloudWatch log group."
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "qdevice" {
  name          = "alias/skylab-qdevice"
  target_key_id = aws_kms_key.qdevice.id
}

resource "aws_ecr_repository" "qdevice" {
  name                 = "skylab-qdevice"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "qdevice" {
  repository = aws_ecr_repository.qdevice.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images."
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      },
    ]
  })
}

module "qdevice" {
  source = "../../modules/ecs-service"

  name       = "qdevice"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  image_uri  = "${aws_ecr_repository.qdevice.repository_url}:${var.image_tag}"

  desired_count            = var.desired_count
  log_kms_key_arn          = aws_kms_key.qdevice.arn
  readonly_root_filesystem = true

  tags = {
    "skylab.io/service" = "qdevice"
  }
}
