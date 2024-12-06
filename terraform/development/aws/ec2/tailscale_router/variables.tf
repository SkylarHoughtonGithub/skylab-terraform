locals {
  us_east_1 = {
    tailscale_router = {
      associate_public_ip_address = true
      ami                         = data.aws_ami.amazon_linux_2.id
      availability_zone           = "us-east-1a"
      create_iam_instance_profile = false
      enable_volume_tags          = true
      instance_type               = "t3.micro"
      key_name                    = "admin"
      subnet_id                   = "subnet-04610b8b2e54b8972"
      user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install wget -y
        amazon-linux-extras install epel -y
        yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
        curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --auth-key=tskey-auth-kLB6bLCeir11CNTRL-UbXC6UvGvbS1EFQVJiCsbSM6kNaFKxCsV --advertise-exit-node
        unzip awscliv2.zip
        ./aws/install
        EOF
      root_block_device = [
        {
          encrypted   = false #TODO: Add customer kms module
          volume_type = "gp3"
          throughput  = 200
          volume_size = 50
        }
      ]
      vpc_security_group_ids = ["sg-00d34d5b71a4fac2e"]

      tags = {
        Name        = "tailscale_router"
        Environment = "dev"
        Project     = "skylab"
        CodeManaged = true

      }
    }
  }
}
