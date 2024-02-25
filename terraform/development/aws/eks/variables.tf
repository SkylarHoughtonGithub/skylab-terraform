variable "eks_api_allowed_cidrs" {
  default = ["172.16.192.0/18"]
}

locals {
  us_east_1 = {
    cluster_version                = "1.27"
    cluster_endpoint_public_access = true
    cluster_name                   = "skylab"
    cluster_addons = {
      coredns = {
        most_recent                 = true
        preserve                    = true
        resolve_conflicts_on_create = true
      }
      kube-proxy = {
        most_recent                 = true
        preserve                    = true
        resolve_conflicts_on_create = true
      }
      vpc-cni = {
        most_recent                 = true
        preserve                    = true
        resolve_conflicts_on_create = true
      }
    }
    create_aws_auth_configmap = true #terraform import module.eks.kubernetes_config_map.aws_auth[0] kube-system/aws-auth
    manage_aws_auth_configmap = true #https://stackoverflow.com/questions/69873472/configmaps-aws-auth-already-exists
    create_iam_role           = true
    iam_role_name             = "skylab-managed-node-group-role"
    aws_auth_roles = [
      {
        rolearn  = "arn:aws:iam::635314249418:user/chicken"
        username = "chicken"
        groups   = ["system:masters"]
      },
      {
        rolearn  = "arn:aws:iam::635314249418:user/tetris"
        username = "tetris"
        groups   = ["system:masters"]
      },
    ]
    eks_managed_node_groups = {
      medium = {
        min_size       = 1
        max_size       = 3
        desired_size   = 3
        disk_size      = 3
        disk_type      = "gp3"
        instance_types = ["t3.medium"]
        capacity_type  = "ON_DEMAND"
      }
    }
    eks_managed_node_group_defaults = {
      ami_type = "AL2_x86_64"
    }
    cluster_security_group_additional_rules = {
      ingress_source_security_group_id = {
        description = "EKS Cluster Private API Access"
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        type        = "ingress"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    node_security_group_additional_rules = {
      ingress_self_all = {
        description = "Node to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        self        = true
      }
      dns-tcp = {
        description = "dns-tcp"
        protocol    = "tcp"
        from_port   = 53
        to_port     = 53
        type        = "ingress"
        cidr_blocks = var.eks_api_allowed_cidrs
      }
      dns-udp = {
        description = "dns-udp"
        protocol    = "udp"
        from_port   = 53
        to_port     = 53
        type        = "ingress"
        cidr_blocks = var.eks_api_allowed_cidrs
      }

      http = {
        description = "http"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        type        = "ingress"
        cidr_blocks = var.eks_api_allowed_cidrs
      }

      https = {
        description = "https"
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        type        = "ingress"
        cidr_blocks = var.eks_api_allowed_cidrs
      }

      # grafana = {
      #   description = "grafana"
      #   protocol    = "tcp"
      #   from_port   = 3000
      #   to_port     = 3000
      #   type        = "ingress"
      #   cidr_blocks = var.eks_api_allowed_cidrs
      # }
      # prometheus = {
      #   description = "prometheus"
      #   protocol    = "tcp"
      #   from_port   = 9000
      #   to_port     = 9100
      #   type        = "ingress"
      #   cidr_blocks = var.eks_api_allowed_cidrs
      # }
      # efs = {
      #   description = "efs"
      #   protocol    = "tcp"
      #   from_port   = 2049
      #   to_port     = 2049
      #   type        = "ingress"
      #   cidr_blocks = var.eks_api_allowed_cidrs
      # }

    }
    subnet_ids = ["subnet-04610b8b2e54b8972", "subnet-0f91e00155d822ebd"]
    vpc_id     = "vpc-0f6c219833fe92be7"
    tags = {
      Name        = "skylab"
      Environment = "dev"
      Project     = "skylab"
      CodeManaged = true
    }
  }
}
