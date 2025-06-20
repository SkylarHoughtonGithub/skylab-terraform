resource "aws_cloudwatch_log_group" "qdevice" {
  name              = "/ecs/proxmox-qdevice"
  retention_in_days = 7
}
