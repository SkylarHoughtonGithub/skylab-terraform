locals {
  k3s_cluster = {
    "test-master" = {
      memory  = 8196
      vcpu    = 4
      root_gb = 20
      data_gb = 100
    }
  }
}