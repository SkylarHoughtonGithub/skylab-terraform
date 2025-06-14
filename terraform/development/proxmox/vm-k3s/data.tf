data "aws_ssm_parameter" "proxmox_token" {
  name = "/proxmox/terraform_provider_token"
}

data "aws_ssm_parameter" "default_password" {
  name = "/kvm/vm_root_password"
}

data "aws_ssm_parameter" "default_ssh_key" {
  name = "/kvm/vm_root_pub_key"
}

locals {
  default_password = data.aws_ssm_parameter.default_password.value
  default_ssh_key  = data.aws_ssm_parameter.default_ssh_key.value
  proxmox_token    = data.aws_ssm_parameter.proxmox_token.value
}
