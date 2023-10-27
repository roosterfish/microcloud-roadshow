resource "lxd_project" "web" {
  name = "web"
  config = {
    "restricted" = "true"
    "restricted.networks.uplinks" = "${var.network_uplink}"
    "restricted.networks.subnets" = "${var.network_uplink}:${var.network_uplink_allowed_subnet}"
    // Use the images from the default project
    "features.images" = false
    // Use project specific networks
    "features.networks" = true
  }
}
