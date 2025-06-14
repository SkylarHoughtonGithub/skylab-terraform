resource "aws_db_subnet_group" "k3s" {
  name       = "skylab-k3s-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "skylab-k3s-db-subnet-group"
    Environment = "lab"
  }
}