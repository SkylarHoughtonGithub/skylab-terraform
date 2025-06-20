output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.qdevice.name
}

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id    = data.aws_vpc.skylab.id
    vpc_name  = var.vpc_name
    subnet_id = data.aws_subnets.skylab_private.ids[0]
    subnet_az = data.aws_availability_zones.available
  }
}

output "instance_connect_command" {
  description = "Command to connect to the EC2 instance"
  value       = "aws ec2-instance-connect ssh --instance-id <INSTANCE_ID> --os-user ec2-user"
}

output "tailscale_status_command" {
  description = "Command to check Tailscale status on instance"
  value       = "sudo tailscale status"
}