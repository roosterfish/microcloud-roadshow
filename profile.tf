resource "lxd_profile" "backend" {
  name = "backend"
  config = {
    "cloud-init.user-data" = <<EOF
#cloud-config
runcmd:
  - mkdir ping
  - echo "Pong from $(hostname)!" > ping/index.html
  - python3 -m http.server 80
EOF
  }
  device {
    type = "disk"
    name = "root"

    properties = {
      pool = "remote"
      path = "/"
    }
  }
  device {
    type = "nic"
    name = "eth0"
    properties = {
        network = lxd_network.web.name
    }
  }
}
