resource "aws_ecs_task_definition" "qdevice" {
  family                   = "proxmox-qdevice"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "qdevice"
      image     = local.proxmox_qdevice_repo
      essential = true
      memory    = 128

      portMappings = [
        {
          containerPort = 5403
          hostPort      = 5403
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.qdevice.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      mountPoints = [
        {
          sourceVolume  = "qdevice-data"
          containerPath = "/etc/corosync"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name      = "qdevice-data"
    host_path = "/opt/qdevice-data"
  }
}