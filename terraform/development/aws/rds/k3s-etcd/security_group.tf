resource "aws_security_group" "rds" {
  name_prefix = "skylab-k3s-rds-"
  vpc_id      = "vpc-0b03763a7a78b363b"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["68.52.182.6 "]
    description = "PostgreSQL access for K3s clusters"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "skylab-k3s-rds-sg"
    Environment = "lab"
  }
}