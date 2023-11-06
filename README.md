# MicroCloud RoadShow Demo

Purpose of this demo is to deploy a OVN load balancer and three backend webservers on top of a MicroCloud.

## Setup

A local microcloud can be setup with the `deploy.sh` script.

Ensure the MicroClouds `UPLINK` network has the `ipv4.routes` setting configured so that we can
assign any of the routed IPs as `network_lb_address_ipv4` to the load balancer:

```bash
lxc network set UPLINK ipv4.routes 192.168.20.200/32
```

Login to one of the MicroCloud machines and create a trust token:

```bash
ssh ubuntu@192.168.20.10
...
lxc config trust add terraform
```

Login to the `terraform` container within the `demo-deployer` project and configure a new remote using the trust token:

```bash
lxc remote add 192.168.20.10
```

Create a new `terraform.tfvars` file in the root of the project with the following contents:

```
remote_address = "192.168.20.10"
network_address_ipv4 = "10.42.1.1/24"
network_address_ipv6 = "fd42:474b:622d:259d::1/64"
network_lb_address_ipv4 = "192.168.20.100"
network_uplink_allowed_subnet = "192.168.20.100/32"
```

Install the Terraform snap:

```
snap install terraform --classic
```

## Demo

Use either Terraform or OpenTofu to deploy the setup:

```
terraform apply -auto-approve
```

Verify using

```
while true; do curl http://192.168.20.100/ping/; sleep .5; done
```

Tear down the deployment with

```
terraform destroy --auto-approve
```
