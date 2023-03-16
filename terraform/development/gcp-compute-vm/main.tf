# Create a single Compute Engine instance
resource "google_compute_instance" "instance" {
  name         = var.instance_vars["name"]
  machine_type = var.instance_vars["machine_type"]
  zone         = var.instance_vars["zone"]
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = var.image["rocky9"]
    }
  }

  # Install NGINX
  metadata_startup_script = "sudo dnf update; sudo dnf install -y epel-release python3 pip3 rsync vim nginx"

  network_interface {
    subnetwork = var.instance_vars["subnet_id"]

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}