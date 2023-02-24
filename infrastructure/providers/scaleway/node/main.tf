terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.10.0, < 3.0.0"
    }
  }
}

resource "scaleway_instance_server" "virtual_machine" {
  count = var.instances

  image             = "ubuntu_focal"
  type              = var.server_type
  name              = format(var.name, count.index)
  cloud_init        = var.cloud_init
  security_group_id = var.security_group_id

  private_network {
    pn_id = var.network_id
  }
}

resource "scaleway_vpc_public_gateway_dhcp_reservation" "main" {
  count = var.instances

  gateway_network_id = var.gateway_id
  mac_address        = scaleway_instance_server.virtual_machine[count.index].private_network.0.mac_address
  ip_address         = "192.168.${var.ip_group}.${count.index}"
}

data "scaleway_vpc_public_gateway_dhcp_reservation" "by_mac_address" {
  count = var.instances

  mac_address = scaleway_instance_server.virtual_machine[count.index].private_network.0.mac_address
  depends_on  = [scaleway_vpc_public_gateway_dhcp_reservation.main]
}
