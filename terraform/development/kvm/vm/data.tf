data "aws_ssm_parameter" "vm_root_pub_key" {
  name = "/kvm/vm_root_pub_key"
}

data "aws_ssm_parameter" "default_password" {
  name = "/kvm/vm_root_password"
}

locals {
  default_password       = data.aws_ssm_parameter.default_password.value
  default_ssh_public_key = data.aws_ssm_parameter.vm_root_pub_key.value
}