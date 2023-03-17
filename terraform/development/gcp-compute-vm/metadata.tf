resource "google_compute_project_metadata" "my_ssh_key" {
  metadata = {
    ssh-keys = file("${path.module}/files/keys/gcp-ansible.pub")
  }
}