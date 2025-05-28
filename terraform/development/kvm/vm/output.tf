# output "vm_ip_addresses" {
#   description = "IP addresses of all VMs"
#   value = {
#     for k, v in module.k3s_cluster_vms : k => v.libvirt_domain.vm.network_interface[0].addresses[0]
#   }
# }

# output "ssh_commands" {
#   description = "SSH commands to connect to VMs"
#   value = {
#     for k, v in module.k3s_cluster_vms : k => "ssh ${v.vm_user}@${v.vm_ip_address}"
#   }
# }