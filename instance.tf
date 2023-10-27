resource "lxd_instance" "web_backend" {
  count = 3
  name  = "web-backend${count.index}"
  image = "ubuntu:jammy"
  profiles = [lxd_profile.backend.name]
  limits = {
    cpu = 4
  }
}
