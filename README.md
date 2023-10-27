# MicroCloud RoadShow Demo

Purpose of this demo is to deploy a OVN load balancer and three backend webservers on top of a MicroCloud.

## Setup

Ensure the MicroClouds `UPLINK` network has the `ipv4.routes` setting configured so that we can
assign any of the routed IPs as `listen_address` to the load balancer.

Create a new `terraform.tfvars` file in the root of the project with the following contents:

```
remote_address = "<Address of one of the MicroClouds LXD server>"
remote_password = "<Token from `lxc config trust add`>"
network_address_ipv4 = "<IPv4 Address for the workloads OVN network e.g. `10.42.1.1/24`>"
network_address_ipv6 = "<IPv6 Address for the workloads OVN network e.g. `fd42:474b:622d:259d::1/64`>"
network_lb_address_ipv4 = "<Address from `ipv4.routes` the load balance will listen on>"
```

Install either the Terraform or OpenTofu snap:

```
snap install terraform --classic
snap install opentofu --classic
```

## Demo

Use either Terraform or OpenTofu to deploy the setup:

```
terraform apply -auto-approve
tofu apply -auto-approve
```

Tear down the deployment with

```
terraform destroy --auto-approve
tofu destroy --auto-approve
```