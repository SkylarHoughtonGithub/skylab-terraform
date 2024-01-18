locals {
  multiple_instances = {
    tailscale = {
      associate_public_ip_address = true
      ami                         = data.aws_ami.amazon_linux.id
      instance_type               = "t3.small"
      availability_zone           = element(module.vpc.azs, 0)
      placement_group      = aws_placement_group.front_end.id
      subnet_id            = element(module.vpc.private_subnets, 0)
      user_data            = <<-EOT
        #!/bin/bash
        sudo yum update -y
        sudo yum install wget
        sudo amazon-linux-extras install java-openjdk11
        sudo amazon-linux-extras install epel -y
        sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo yum install jenkins -y
        sudo systemctl enable jenkins
        sudo systemctl start jenkins
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
