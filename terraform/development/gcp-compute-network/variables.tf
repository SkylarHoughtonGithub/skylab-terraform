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