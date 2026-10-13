# Reusable Fargate service. One ECS cluster, one task definition, one
# service — a thin wrapper for stacks that run a single long-lived
# container (qdevice is the first consumer). Networking is awsvpc with
# an egress-only security group; callers wire ingress elsewhere if needed.

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_arn

  tags = var.tags
}

resource "aws_security_group" "this" {
  name        = "${var.name}-task"
  description = "Egress-only SG for the ${var.name} Fargate task."
  vpc_id      = var.vpc_id

  # Egress-only. Ingress is added by the caller if the service needs it.
  egress {
    description      = "Allow all egress."
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

# --- Execution role: pulls image, writes logs, reads secrets ---
data "aws_iam_policy_document" "execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name}-ecs-execution"
  description        = "ECS task execution role for ${var.name}."
  assume_role_policy = data.aws_iam_policy_document.execution_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution_extra" {
  for_each   = toset(var.exec_role_additional_policy_arns)
  role       = aws_iam_role.execution.name
  policy_arn = each.value
}

# --- Task role: what the container itself can call on AWS ---
resource "aws_iam_role" "task" {
  name               = "${var.name}-ecs-task"
  description        = "ECS task role for ${var.name}."
  assume_role_policy = data.aws_iam_policy_document.execution_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "task_extra" {
  for_each   = toset(var.task_role_additional_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = each.value
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = var.image_uri
      essential = true

      readonlyRootFilesystem = var.readonly_root_filesystem

      environment = [
        for k, v in var.environment : {
          name  = k
          value = v
        }
      ]

      secrets = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.name
        }
      }
    }
  ])

  tags = var.tags
}

data "aws_region" "current" {}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  enable_execute_command = var.enable_exec

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }

  tags = var.tags
}
