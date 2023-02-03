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
  image       = "ubuntu-20.04"
  server_type = var.server_type
  location    = var.location

  user_data = var.cloud_init

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

  labels = merge(
    {
      managed_by = "terraform"
    },
    var.labels
  )
}
