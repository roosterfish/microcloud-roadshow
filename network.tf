resource "lxd_network" "web" {
  name = "web"
  type = "ovn"
  config = {
    "network" = var.network_uplink
    "ipv4.address" = var.network_address_ipv4
    "ipv4.nat" = "true"
    "ipv6.address" = var.network_address_ipv6
    "ipv6.nat" = "true"
  }
  project = lxd_project.web.name
}

resource "lxd_network_lb" "web_to_backend" {
  network = lxd_network.web.name
  listen_address = var.network_lb_address_ipv4
  project = lxd_project.web.name

  dynamic "backend" {
    for_each = lxd_instance.web_backend
    content {
      name = backend.value.name
      target_address = backend.value.ipv4_address
      target_port = "80"
    }
  }

  port {
    protocol = "tcp"
    listen_port = "80"
    target_backend = [for k, v in lxd_instance.web_backend : v.name]
  }
}
