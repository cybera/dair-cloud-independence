terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

resource "openstack_compute_keypair_v2" "django" {
  name       = "${var.name}"
  public_key = "${file("../../key/id_rsa.pub")}"
}

resource "openstack_networking_floatingip_v2" "public_ip" {
  pool = "public"
}

resource "openstack_networking_secgroup_v2" "django" {
  name        = "${var.name}.${var.domain}"
  description = "Rules for ${var.name}.${var.domain}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction        = "ingress"
  ethertype        = "IPv4"
  protocol         = "icmp"
  remote_ip_prefix = "${var.allowed_net}"

  security_group_id = "${openstack_networking_secgroup_v2.django.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp_ssh" {
  direction        = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 22
  port_range_max   = 22
  remote_ip_prefix = "${var.allowed_net}"

  security_group_id = "${openstack_networking_secgroup_v2.django.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp_http" {
  direction        = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 80
  port_range_max   = 80
  remote_ip_prefix = "${var.allowed_net}"

  security_group_id = "${openstack_networking_secgroup_v2.django.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp_sensu" {
  direction        = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 8000
  port_range_max   = 8000
  remote_ip_prefix = "${var.allowed_net}"

  security_group_id = "${openstack_networking_secgroup_v2.django.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp_grafana" {
  direction        = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 3000
  port_range_max   = 3000
  remote_ip_prefix = "${var.allowed_net}"

  security_group_id = "${openstack_networking_secgroup_v2.django.id}"
}

resource "openstack_compute_instance_v2" "django" {
  name            = "${var.name}.${var.domain}"
  image_name      = "Ubuntu 18.04"
  flavor_name     = "m1.small"
  key_pair        = "${openstack_compute_keypair_v2.django.name}"
  security_groups = ["${openstack_networking_secgroup_v2.django.name}"]

  network {
    name = "${var.network_name}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "public_ip" {
  instance_id = "${openstack_compute_instance_v2.django.id}"
  floating_ip = "${openstack_networking_floatingip_v2.public_ip.address}"
}

# Deploy the application to the virtual machine
# module "deploy_app" {
#  source     = "../deploy_app"
#  ip_address = "${openstack_compute_floatingip_associate_v2.public_ip.floating_ip}"
#  ssh_key    = "${file("../../key/id_rsa")}"
#}

output "public_ip" {
  value = "${openstack_compute_floatingip_associate_v2.public_ip.floating_ip}"
}

output "polls_url" {
  value = "http://${openstack_compute_floatingip_associate_v2.public_ip.floating_ip}/polls"
}

