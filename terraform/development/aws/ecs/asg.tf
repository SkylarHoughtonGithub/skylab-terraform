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