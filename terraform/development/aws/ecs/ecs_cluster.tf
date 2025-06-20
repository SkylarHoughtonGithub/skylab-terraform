resource "aws_ecs_cluster" "qdevice" {
  name = "proxmox-qdevice"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "proxmox-qdevice"
  }
}

resource "aws_ecs_service" "qdevice" {
  name            = "proxmox-qdevice"
  cluster         = aws_ecs_cluster.qdevice.id
  task_definition = aws_ecs_task_definition.qdevice.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.qdevice.name
    weight            = 100
  }
}

resource "aws_cloudwatch_log_group" "qdevice" {
  name              = "/ecs/proxmox-qdevice"
  retention_in_days = 7
}

resource "aws_ecs_capacity_provider" "qdevice" {
  name = "proxmox-qdevice-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.qdevice.arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }

    managed_termination_protection = "DISABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "qdevice" {
  cluster_name = aws_ecs_cluster.qdevice.name

  capacity_providers = [aws_ecs_capacity_provider.qdevice.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.qdevice.name
  }
}