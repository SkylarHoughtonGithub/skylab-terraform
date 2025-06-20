locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name        = aws_ecs_cluster.qdevice.name
    tailscale_api_token = data.aws_ssm_parameter.tailscale_api_token.value
  }))

  proxmox_qdevice_tag = "latest"
}

locals {
  proxmox_qdevice_repo = "${data.aws_ecr_repository.qdevice.repository_url}:${local.proxmox_qdevice_tag}"
}