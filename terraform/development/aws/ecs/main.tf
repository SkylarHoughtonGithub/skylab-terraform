# ECS Cluster
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

# Launch Template
resource "aws_launch_template" "qdevice" {
  name_prefix   = "proxmox-qdevice-"
  description   = "Launch template for Proxmox QDevice ECS instance"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.qdevice.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "proxmox-qdevice"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "qdevice" {
  name                      = "proxmox-qdevice-asg"
  vpc_zone_identifier       = data.aws_subnets.skylab_public.ids
  target_group_arns         = []
  health_check_type         = "EC2"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.qdevice.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "proxmox-qdevice"
    propagate_at_launch = true
  }
}

# ECS Capacity Provider
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

# Task Definition
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

# ECS Service
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
