resource "google_compute_firewall" "icmp" {
  name          = "allow-icmp-all"
  direction     = "INGRESS"
  network       = var.network_id
  priority      = 900
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}
