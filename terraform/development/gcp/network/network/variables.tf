# GCP authentication file

variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
  default     = "~/.gcp/homelab-369103-25b92b6efc0d.json"
}
variable "network_vars" {
  type = map(string)
  default = {
    "name" = "homelab-network"
    "mtu"  = "1500"
  }
}
variable "subnet_vars" {
  type = map(string)
  default = {
    "name"   = "homelab-subnet"
    "cidr"   = "10.0.10.0/24"
    "region" = "us-central1"
  }
}