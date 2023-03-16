resource "google_compute_firewall" "flask" {
  name          = "allow-flask-all"
  direction     = "INGRESS"
  network       = var.network_id
  priority      = 1100
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
}
