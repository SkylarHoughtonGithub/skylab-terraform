resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  direction     = "INGRESS"
  network       = module.google_compute_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
  
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}
