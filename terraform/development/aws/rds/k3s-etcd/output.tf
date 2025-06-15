output "cluster1_connection_string" {
  sensitive = true
  value     = "postgres://k3s:${random_password.k3s_user_password.result}@${aws_db_instance.k3s.endpoint}:5432/k3s_cluster1?sslmode=require"
}

output "cluster2_connection_string" {
  sensitive = true
  value     = "postgres://k3s:${random_password.k3s_user_password.result}@${aws_db_instance.k3s.endpoint}:5432/k3s_cluster2?sslmode=require"
}

output "ssm_parameters" {
  value = {
    db_endpoint    = aws_ssm_parameter.k3s_db_endpoint.value
    db_username    = aws_ssm_parameter.k3s_db_username.value
    db_password    = aws_ssm_parameter.k3s_db_password.value
    cluster1_token = aws_ssm_parameter.k3s_cluster1_token.value
    cluster2_token = aws_ssm_parameter.k3s_cluster2_token.value
  }
  sensitive = true
}
