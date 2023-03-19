# gcloud auth application-default login
terraform {
  backend "gcs" {
    bucket = "shoutsky-state"
    prefix = "terraform/storage-bucket"
  }
}

provider "google" {
  project = "homelab-369103"
  region  = "us-central1"
  zone    = "us-central1-c"
}