resource "hcloud_network" "network" {
  name     = format(module.common.name_format, local.location, "network")
  ip_range = "10.2.0.0/16"

  labels = {
    managed_by = "terraform"
  }
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "server"
  network_id   = hcloud_network.network.id
  network_zone = data.hcloud_location.location.network_zone
  ip_range     = "10.2.0.0/24"
}

resource "hcloud_firewall" "firewall" {
  name = format(module.common.name_format, local.location, "firewall")

  dynamic "rule" {
    for_each = toset(module.k3s_setup.firewall_ports)
    content {
      description = rule.value.name
      port        = rule.value.start == rule.value.end ? rule.value.start : "${rule.value.start}-${rule.value.end}"
      direction   = try(rule.value.direction, "in")
      protocol    = try(lower(rule.value.protocol), "tcp")
      source_ips = try(rule.value.source_ips, [
        "0.0.0.0/0",
        "::/0"
      ])
    }
  }
}
