variable "remote_name" {
    type = string
    default = "microcloud"
}
variable "remote_address" {
    type = string
}
variable "network_uplink" {
    type = string
    default = "UPLINK"
}
variable "network_uplink_allowed_subnet" {
    type = string
}
variable "network_address_ipv4" {
    type = string
}
variable "network_address_ipv6" {
    type = string
}
variable "network_lb_address_ipv4" {
    type = string
}
