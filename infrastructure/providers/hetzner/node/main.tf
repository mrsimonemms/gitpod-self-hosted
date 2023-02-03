terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.0.0, < 2.0.0"
    }
  }
}

resource "hcloud_server" "virtual_machine" {
  count = var.instances

  name        = format(var.name, count.index)
  image       = "ubuntu-22.04"
  server_type = var.server_type
  location    = var.location

  firewall_ids = [
    var.firewall
  ]

  network {
    network_id = var.network_id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  placement_group_id = var.placement_group
  ssh_keys = [
    var.ssh_key
  ]

  labels = {
    managed_by = "terraform"
  }
}

resource "hcloud_load_balancer_target" "virtual_machine" {
  count = var.instances

  load_balancer_id = var.load_balancer
  server_id        = hcloud_server.virtual_machine[count.index].id
  type             = "server"
}
