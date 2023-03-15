resource "google_compute_firewall" "flask" {
  name    = "flask-app-firewall"
  direction     = "INGRESS"
  network       = module.google_compute_network.id
  priority      = 1100
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
}
