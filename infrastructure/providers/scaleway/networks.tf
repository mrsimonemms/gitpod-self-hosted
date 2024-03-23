resource "scaleway_vpc_private_network" "network" {
  name = format(module.common.name_format, local.region, "network")
}

resource "scaleway_vpc_public_gateway_ip" "gw01" {}

resource "scaleway_vpc_public_gateway_dhcp" "dhcp01" {
  subnet = "192.168.0.0/16"
}

resource "scaleway_vpc_public_gateway" "pg01" {
  name            = format(module.common.name_format, local.region, "public_gateway")
  type            = "VPC-GW-S"
  ip_id           = scaleway_vpc_public_gateway_ip.gw01.id
  bastion_enabled = true
}

resource "scaleway_vpc_gateway_network" "main" {
  gateway_id         = scaleway_vpc_public_gateway.pg01.id
  private_network_id = scaleway_vpc_private_network.network.id
  dhcp_id            = scaleway_vpc_public_gateway_dhcp.dhcp01.id
  cleanup_dhcp       = true
  enable_masquerade  = true
}

resource "scaleway_vpc_public_gateway_pat_rule" "kubernetes" {
  gateway_id   = scaleway_vpc_public_gateway.pg01.id
  private_ip   = module.k3s_manager.reserved_ips[0].ip_address
  private_port = 6443
  public_port  = 6443
  protocol     = "both"
  depends_on   = [scaleway_vpc_gateway_network.main, scaleway_vpc_private_network.network]
}

resource "scaleway_instance_security_group" "network" {
  name = format(module.common.name_format, local.region, "network")

  # Drop any inbound connection not defined
  inbound_default_policy = "drop"
  # Allow all outbound connections
  outbound_default_policy = "accept"

  dynamic "inbound_rule" {
    // Get from common module due to circular dependency
    for_each = toset(module.common.firewall_ports)
    content {
      action     = "accept"
      port       = inbound_rule.value.start == inbound_rule.value.end ? inbound_rule.value.start : null
      port_range = inbound_rule.value.start != inbound_rule.value.end ? "${inbound_rule.value.start}-${inbound_rule.value.end}" : null
      protocol   = try(inbound_rule.value.protocol, "tcp")
    }
  }
}
