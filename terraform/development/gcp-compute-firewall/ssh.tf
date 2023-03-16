resource "google_compute_firewall" "ssh" {
  name          = "allow-ssh-all"
  direction     = "INGRESS"
  network       = var.network_id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}
