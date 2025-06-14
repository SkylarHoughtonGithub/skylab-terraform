resource "aws_db_subnet_group" "k3s" {
  name       = "skylab-k3s-db-subnet-group"
  subnet_ids = ["subnet-0c76bff511c4be88b", "subnet-098f907e237006ac8"]

  tags = {
    Name        = "skylab-k3s-db-subnet-group"
    Environment = "lab"
  }
}