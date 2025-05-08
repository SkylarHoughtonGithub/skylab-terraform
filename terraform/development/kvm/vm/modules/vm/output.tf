output "vm_id" {
  value = libvirt_domain.vm.id
}

output "vm_name" {
  value = libvirt_domain.vm.name
}

output "ip_addresses" {
  description = "IP addresses of the VM's network interfaces"
  value       = libvirt_domain.vm.network_interface.*.addresses
}