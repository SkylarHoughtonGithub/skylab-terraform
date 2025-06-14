resource "proxmox_vm_qemu" "alma9-test" {
  name        = "alma9-test-vm"
  target_node = "host1"

  clone = "alma9-template"
  cpu {
    cores   = 4
    sockets = 1
  }

  memory = 8192

  disk {
    slot     = "scsi0"
    size     = "40G"
    type     = "disk"
    storage  = "local-zfs"
    iothread = true
  }

  disk {
    slot     = "scsi1"
    size     = "100G"
    type     = "disk"
    storage  = "local-zfs"
    iothread = true
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type    = "cloud-init"
  ipconfig0  = "ip=192.168.80.100/24,gw=192.168.80.1"
  nameserver = "8.8.8.8,8.8.4.4"
  sshkeys    = local.default_ssh_key

  onboot   = true
  agent    = 1
  bootdisk = "scsi0"
  bios     = "ovmf"
}