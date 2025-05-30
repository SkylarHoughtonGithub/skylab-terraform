###############################################
# variables.tf - Module Input Variables
###############################################

# Basic VM Configuration
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "domain" {
  description = "domain for FQDN"
  type        = string
}

variable "memory" {
  description = "Amount of memory in MiB"
  type        = number
  default     = 2048
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
}

variable "cpu_mode" {
  description = "CPU mode (host-passthrough, host-model, custom)"
  type        = string
  default     = "custom"
}

# Storage Configuration
variable "storage_pool" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "base_image_path" {
  description = "URL to the base OS image"
  type        = string
  default = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
}

variable "root_volume_size" {
  description = "Size of the root volume in bytes"
  type        = number
  default     = 10 * 1024 * 1024 * 1024 # 10 GiB
}

variable "additional_disks" {
  description = "Map of additional disks to create"
  type = map(object({
    size = number # Size in bytes
  }))
  default = {}
}

# Network Configuration
variable "network_interfaces" {
  description = "List of network interface configurations"
  type = list(object({
    network_name   = string
    mac            = optional(string)
    wait_for_lease = optional(bool, true)
  }))
  default = [{
    network_name   = "default"
    wait_for_lease = true
  }]
}

variable "custom_network_config" {
  description = "Custom network config in cloud-init format (overrides generated network config)"
  type        = string
  default     = ""
}

# Authentication & User Configuration
variable "vm_user" {
  description = "Default user to create via cloud-init"
  type        = string
  default     = "ansible"
}

variable "vm_password" {
  description = "Password for the default user (leave empty for SSH-only authentication)"
  type        = string
  default     = "password"
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for default user authentication"
  type        = string
}

# Advanced VM Options
variable "autostart" {
  description = "Whether to autostart the VM"
  type        = bool
  default     = true
}

variable "enable_qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "enable_uefi" {
  description = "Boot using UEFI instead of BIOS"
  type        = bool
  default     = false
}

# Cloud-Init Customization
variable "custom_cloud_init_commands" {
  description = "Custom commands to run during cloud-init"
  type        = list(string)
  default     = []
}
