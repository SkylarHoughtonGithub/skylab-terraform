output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.k3s.endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.k3s.port
}

output "cluster1_connection_string" {
  description = "Connection string for cluster1"
  value       = "postgres://k3s_user:${random_password.k3s_user_password.result}@${aws_db_instance.k3s.endpoint}:5432/k3s_cluster1?sslmode=require"
  sensitive   = true
}

output "cluster2_connection_string" {
  description = "Connection string for cluster2"
  value       = "postgres://k3s_user:${random_password.k3s_user_password.result}@${aws_db_instance.k3s.endpoint}:5432/k3s_cluster2?sslmode=require"
  sensitive   = true
}

output "ssm_parameter_paths" {
  description = "SSM Parameter Store paths"
  value = {
    db_endpoint    = aws_ssm_parameter.k3s_db_endpoint.name
    db_username    = aws_ssm_parameter.k3s_db_username.name
    db_password    = aws_ssm_parameter.k3s_db_password.name
    cluster1_token = aws_ssm_parameter.k3s_cluster1_token.name
    cluster2_token = aws_ssm_parameter.k3s_cluster2_token.name
  }
}

output "security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}