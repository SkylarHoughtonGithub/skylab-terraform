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