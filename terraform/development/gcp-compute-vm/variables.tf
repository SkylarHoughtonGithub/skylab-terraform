variable "tags" {
  default = ["allow-flask-all", "allow-ssh-all", "allow-icmp-all"]
}


variable "image" {
  type = map(string)
  default = {
    cos97lts      = "cos-cloud/cos-97-lts"
    rocky8        = "rocky-linux-cloud/rocky-linux-8-optimized-gcp"
    rocky9        = "rocky-linux-cloud/rocky-linux-9-optimized-gcp"
    centos7       = "centos-cloud/centos-7"
    debian11      = "debian-cloud/debian-11"
    winserver2019 = "windows-cloud/windows-2019"
  }
}

variable "instance_vars" {
  type = map(string)
  default = {
    name         = "rocky9-web1"
    machine_type = "f1-micro"
    subnet_id : "homelab-subnet"
    zone = "us-central1-c"
  }
}