# Define base volume for VM
resource "libvirt_volume" "base_volume" {
  name   = "${var.vm_name}-base"
  pool   = var.storage_pool
  source = var.base_image_path
  format = "qcow2"
}

# Define root volume for VM
resource "libvirt_volume" "root_volume" {
  name           = "${var.vm_name}-root"
  pool           = var.storage_pool
  base_volume_id = libvirt_volume.base_volume.id
  size           = var.root_volume_size * 1024 * 1024 * 1024
}

# Dynamic additional disks
resource "libvirt_volume" "additional_volume" {
  for_each = var.additional_disks

  name   = "${var.vm_name}-${each.key}"
  pool   = var.storage_pool
  size   = each.value.size * 1024 * 1024 * 1024
  format = "qcow2"
}

# Define cloud-init disk for VM provisioning
resource "libvirt_cloudinit_disk" "cloud_init" {
  name = "${var.vm_name}-cloudinit.iso"
  user_data = templatefile("${path.module}/templates/cloud_init.tftpl", {
    hostname        = var.vm_name
    domain          = var.domain
    ssh_key         = var.ssh_public_key
    user            = var.vm_user
    password        = var.vm_password
    custom_commands = var.custom_cloud_init_commands
  })

  network_config = var.custom_network_config != "" ? var.custom_network_config : file("${path.module}/templates/network_config.tftpl")
}

# Define the VM domain
resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.memory
  vcpu   = var.vcpu

  # Use qemu-agent for improved guest management
  qemu_agent = var.enable_qemu_agent

  # CPU configuration
  cpu {
    mode = var.cpu_mode
  }

  # Disk configuration
  disk {
    volume_id = libvirt_volume.root_volume.id
  }

  # Dynamic block for additional disks
  dynamic "disk" {
    for_each = libvirt_volume.additional_volume

    content {
      volume_id = disk.value.id
    }
  }

  # Cloud-init disk
  cloudinit = libvirt_cloudinit_disk.cloud_init.id

  # Dynamic block for network interfaces
  dynamic "network_interface" {
    for_each = var.network_interfaces

    content {
      network_name   = network_interface.value.network_name
      mac            = lookup(network_interface.value, "mac", null)
      wait_for_lease = lookup(network_interface.value, "wait_for_lease", true)
    }
  }

  # Console configuration
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # Autostart configuration
  autostart = var.autostart

  # VM lifecycle customization
  lifecycle {
    ignore_changes = [
      disk,
      network_interface,
    ]
  }

  # NVRAM configuration for UEFI boot if enabled
  dynamic "nvram" {
    for_each = var.enable_uefi ? [1] : []
    content {
      file = "/var/lib/libvirt/qemu/nvram/${var.vm_name}_VARS.fd"
    }
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}
