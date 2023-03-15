variable "image" {
  type = "map"
  default = {
    cos97lts = "cos-cloud/cos-97-lts"
    rocky8 = "rocky-linux-cloud/rocky-linux-8-optimized-gcp"
    rocky9 = "rocky-linux-cloud/rocky-linux-9-optimized-gcp"
    centos7 = "centos-cloud/centos-7"
    debian11 = "debian-cloud/debian-11"
    winserver2019 = "windows-cloud/windows-2019"
    }
}

variable "instance_vars" {
  type = "map"
  default = {
    name = "rocky9-web1"
    machine_type = "f1-micro"
    zone = "us-east4-a"
    tags = ["ssh"]
  }
}