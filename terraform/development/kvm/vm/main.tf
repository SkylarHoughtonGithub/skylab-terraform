module "okd_master_vms" {
  source = "./modules/vm"

  vm_name          = "master-0"
  domain           = "skylarhoughtongithub.com"
  memory           = 4096
  vcpu             = 4
  base_image_path  = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/42.20250410.3.2/x86_64/fedora-coreos-42.20250410.3.2-qemu.x86_64.qcow2.xz"
  root_volume_size = 20 * 1024 * 1024 * 1024 # 20 GiB
  ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAA... user@example.com"

  # Additional disks using dynamic blocks (no count needed!)
  additional_disks = {
    "data" = {
      size = 50 * 1024 * 1024 * 1024 # 50 GiB
    },
    "backup" = {
      size = 100 * 1024 * 1024 * 1024 # 100 GiB
    }
  }
}