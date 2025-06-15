resource "random_password" "k3s_user_password" {
  length  = 16
  special = true
}

resource "random_password" "cluster1_token" {
  length  = 32
  special = false
}

resource "random_password" "cluster2_token" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "k3s_db_endpoint" {
  name  = "/k3s/db_endpoint"
  type  = "String"
  value = aws_db_instance.k3s.endpoint

  tags = {
    Environment = "lab"
  }
}

resource "aws_ssm_parameter" "k3s_db_username" {
  name  = "/k3s/db_username"
  type  = "SecureString"
  value = "k3s"

  tags = {
    Environment = "lab"
  }
}

resource "aws_ssm_parameter" "k3s_db_password" {
  name  = "/k3s/db_password"
  type  = "SecureString"
  value = random_password.k3s_user_password.result

  tags = {
    Environment = "lab"
  }
}

resource "aws_ssm_parameter" "k3s_cluster1_token" {
  name  = "/k3s/cluster1/token"
  type  = "SecureString"
  value = random_password.cluster1_token.result

  tags = {
    Environment = "lab"
  }
}

resource "aws_ssm_parameter" "k3s_cluster2_token" {
  name  = "/k3s/cluster2/token"
  type  = "SecureString"
  value = random_password.cluster2_token.result

  tags = {
    Environment = "lab"
  }
}
