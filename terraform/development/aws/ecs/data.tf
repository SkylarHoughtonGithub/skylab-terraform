data "aws_region" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "skylab" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "skylab_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.skylab.id]
  }

  filter {
    name   = "tag:type"
    values = ["public"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "tailscale_api_token" {
  name = "/tailscale/api_token"
}

data "aws_ecr_repository" "qdevice" {
  name = "proxmox-qdevice"
}