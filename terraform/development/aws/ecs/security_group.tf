resource "aws_security_group" "qdevice" {
  name_prefix = "proxmox-qdevice-"
  description = "Security group for Proxmox QDevice"
  vpc_id      = data.aws_vpc.skylab.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Tailscale UDP
  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "proxmox-qdevice-sg"
  }
}