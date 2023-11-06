terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
  }
}

provider "lxd" {
  lxd_remote {
    name = var.remote_name
    scheme = "https"
    address = var.remote_address
    default = true
  }
  accept_remote_certificate = true
}
