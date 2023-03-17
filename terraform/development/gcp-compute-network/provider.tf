# gcloud auth application-default login
provider "google" {
  project     = "homelab-369103"
  credentials = file(var.gcp_auth_file)
  region      = "us-central1"
  zone        = "us-central1-c"
}