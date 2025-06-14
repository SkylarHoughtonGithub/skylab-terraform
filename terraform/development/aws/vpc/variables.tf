variable "networks_use2" {
  default = {
    "skylab" = {
      azs  = ["us-east-2a", "us-east-2c"]
      cidr = "192.168.0.0/16"
      enable_nat_gateway = false
      enable_vpn_gateway = false
      single_nat_gateway = false
      one_nat_gateway_per_az = false
      map_public_ip_on_launch = true
      
      private_subnets = []
      
      public_subnets = [
        "192.168.10.0/24",
      ]
      
      tags = {
        environment = "lab"
        project     = "skylab"
        network     = "public"    # Changed from "private" to "public"
      }
    }
  }
}