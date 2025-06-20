locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name        = aws_ecs_cluster.qdevice.name
    tailscale_api_token = data.aws_ssm_parameter.tailscale_api_token
  }))
}