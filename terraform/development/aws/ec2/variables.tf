locals {
  us_east_1 = {
    jenkins = {
      associate_public_ip_address = true
      ami                         = data.aws_ami.amazon_linux_2.id
      availability_zone           = "us-east-1a"
      create_iam_instance_profile = false
      enable_volume_tags          = true
      instance_type               = "t3.medium"
      key_name                    = "admin"
      subnet_id                   = "subnet-04610b8b2e54b8972"
      user_data                   = <<-EOT
        #!/bin/bash
        sudo yum update -y
        sudo yum install wget
        sudo amazon-linux-extras install java-openjdk11
        sudo amazon-linux-extras install epel -y
        sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        sudo yum install jenkins -y
        sudo systemctl enable jenkins
        sudo systemctl start jenkins
        EOT
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
        Name        = "jenkins1"
        environment = "dev"
        project     = "skylab"
        codemanaged = true

      }
    }
  }

  # us_east_1c = { 
  #   tailscale = {
  #     associate_public_ip_address = true
  #     ami                         = data.aws_ami.amazon_linux.id
  #     instance_type               = "t3.small"
  #     availability_zone           = element(module.vpc.azs, 0)
  #     key_name                    = "admin"
  #     placement_group      = aws_placement_group.web.id
  #     subnet_id            = element(module.vpc.private_subnets, 0)
  #     user_data            = <<-EOT
  #       #!/bin/bash
  #       sudo yum install yum-utils
  #       sudo yum-config-manager --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2/tailscale.repo
  #       sudo yum install tailscale
  #       sudo systemctl enable --now tailscaled
  #       sudo tailscale up
  #       EOT
  #     #   root_block_device = [
  #     #     {
  #     #       encrypted   = true
  #     #       volume_type = "gp3"
  #     #       throughput  = 200
  #     #       volume_size = 50
  #     #       tags = {
  #     #         Name = "my-root-block"
  #     #       }
  #     #     }
  #     #   ]

  #     tags = {
  #       Name = "jenkins1"
  #       environment = "dev"
  #       project     = "skylab"
  #       codemanaged = true
  #     }
  #   }
  # }
}
