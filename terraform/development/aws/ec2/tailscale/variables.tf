locals {
  multiple_instances = {
    tailscale = {
      associate_public_ip_address = true
      ami                         = data.aws_ami.amazon_linux.id
      instance_type               = "t3.small"
      availability_zone           = element(module.vpc.azs, 0)
      placement_group      = aws_placement_group.web.id
      subnet_id            = element(module.vpc.private_subnets, 0)
      user_data            = <<-EOT
        #!/bin/bash
        sudo yum install yum-utils
        sudo yum-config-manager --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2/tailscale.repo
        sudo yum install tailscale
        sudo systemctl enable --now tailscaled
        sudo tailscale up
        EOT
      #   root_block_device = [
      #     {
      #       encrypted   = true
      #       volume_type = "gp3"
      #       throughput  = 200
      #       volume_size = 50
      #       tags = {
      #         Name = "my-root-block"
      #       }
      #     }
      #   ]

    }
    tags = {
      Name    = "one"
      subnet  = "private"
      managed = true
    }
  }
}
