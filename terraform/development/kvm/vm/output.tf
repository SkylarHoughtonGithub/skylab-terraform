output "vm_ip_addresses" {
  description = "IP addresses of all VMs"
  value = {
    for k, v in module.k3s_cluster_vms : k => v.libvirt_domain.vm.network_interface[0].addresses[0]
  }
}