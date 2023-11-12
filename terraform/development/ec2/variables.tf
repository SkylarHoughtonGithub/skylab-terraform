
locals {
  region = "us-east-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

locals {
  multiple_instances = {
    one = {
      associate_public_ip_address = true
      ami                         = data.aws_ami.amazon_linux.id
      instance_type               = "t3.small"
      availability_zone           = element(module.vpc.azs, 0)
      #   create_iam_instance_profile = false
      #   iam_role_policies = {
      #     AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
      #   }
      iam_role_description = "IAM role for EC2 instance"
      placement_group      = aws_placement_group.web.id
      subnet_id            = element(module.vpc.private_subnets, 0)
      user_data            = <<-EOT
        #!/bin/bash
        echo "Hello Terraform!"
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