resource "digitalocean_vpc" "network" {
  name     = format(module.common.name_format, local.location, "network")
  region   = var.location
  ip_range = "10.2.0.0/16"
}

resource "digitalocean_firewall" "web" {
  name = format(module.common.name_format, local.location, "firewall-${random_integer.label_id.result}")

  depends_on = [
    module.k3s_manager,
    module.k3s_nodes,
  ]

  tags = [local.node_label]

  dynamic "inbound_rule" {
    for_each = toset(module.k3s_setup.firewall_ports)
    content {
      protocol   = lower(inbound_rule.value.protocol)
      port_range = inbound_rule.value.start == inbound_rule.value.end ? inbound_rule.value.start : "${inbound_rule.value.start}-${inbound_rule.value.end}"
      source_addresses = try(inbound_rule.value.source_ips, [
        "0.0.0.0/0",
        "::/0"
      ])
    }
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol   = "tcp"
    port_range = "1-65535"
    destination_addresses = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  outbound_rule {
    protocol   = "udp"
    port_range = "1-65535"
    destination_addresses = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  outbound_rule {
    protocol = "icmp"
    destination_addresses = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
