module "k3s_cluster_vms" {
  for_each = local.k3s_cluster
  source   = "./modules/vm"

  base_image_path  = "http://host1.local/iso/alma9_base.qcow2"
  domain           = "skylarhoughtongithub.com"
  memory           = each.value.memory
  root_volume_size = each.value.root_gb
  vcpu             = each.value.vcpu
  vm_name          = each.key
  vm_password      = local.default_password
  vm_user          = "ansible"
  ssh_public_key   = local.default_ssh_public_key

  network_interfaces = [{
    network_name   = "br0"
    wait_for_lease = true
  }]

  additional_disks = {
    "data" = {
      size = each.value.data_gb
    }
  }
}