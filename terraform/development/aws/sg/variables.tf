variable "sgs" {
  default = {
    "public-jenkins" = {
      name                = "public-jenkins"
      description         = "Public Jenkins Access"
      ingress_rules       = ["https-443-tcp"]
      ingress_cidr_blocks = ["192.168.0.0/16"]
      ingress_with_cidr_blocks = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          description = "SSH - Isolated"
          cidr_blocks = "170.103.87.244/32"
        },
        {
          from_port   = 53
          to_port     = 53
          protocol    = "udp"
          description = "DNS - Open"
          cidr_blocks = "170.103.87.244/32"
        },
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          description = "Jenkins - Open"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port   = 9000
          to_port     = 9000
          protocol    = "tcp"
          description = "SonarQube - Open"
          cidr_blocks = "0.0.0.0/0"
        },
      ]
      egress_rules = ["all-all"]
      egress_with_cidr_blocks = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = -1
          description = "Egress - Open"
          cidr_blocks = "0.0.0.0/0"
        },
      ]
    }
  }
}
