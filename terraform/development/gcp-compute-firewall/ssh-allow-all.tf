resource "google_compute_firewall" "ssh-allow-all" {
  name          = "ssh-allow-all"
  direction     = "INGRESS"
  network       = var.network_id
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}
