resource "aws_db_instance" "k3s" {
  identifier                   = "skylab-k3s-etcd"
  engine                       = "postgres"
  engine_version               = "15.4"
  instance_class               = "db.t3.micro"
  allocated_storage            = 20
  max_allocated_storage        = 20 * 2
  storage_type                 = "gp2"
  storage_encrypted            = true
  db_name                      = "postgres"
  username                     = "etcd"
  password                     = data.aws_ssm_parameter.etcd_master_password
  db_subnet_group_name         = aws_db_subnet_group.k3s.name
  vpc_security_group_ids       = [aws_security_group.rds.id]
  publicly_accessible          = true
  port                         = 5432
  backup_retention_period      = 7
  backup_window                = "03:00-04:00"
  maintenance_window           = "sun:04:00-sun:05:00"
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true
  deletion_protection          = true
  skip_final_snapshot          = true
  auto_minor_version_upgrade   = true

  tags = {
    Name        = "skylab-k3s-etcd"
    environment = "lab"
    project     = "skylab"
  }
}
