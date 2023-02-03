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
    for_each = toset(local.firewall)
    content {
      description = rule.value.description
      port        = rule.value.port
      direction   = try(rule.value.direction, "in")
      protocol    = try(rule.value.protocol, "tcp")
      source_ips = try(rule.value.source_ips, [
        "0.0.0.0/0",
        "::/0"
      ])
    }
  }
}
