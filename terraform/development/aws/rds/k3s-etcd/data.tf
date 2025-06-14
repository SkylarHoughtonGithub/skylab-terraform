data "aws_ssm_parameter" "etcd_master_password" {
  name = "/k3s/etcd_master_password"
}
