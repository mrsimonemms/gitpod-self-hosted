terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

resource "scaleway_instance_server" "virtual_machine" {
  image      = "ubuntu_focal"
  type       = var.server_type
  count      = var.instances
  name       = format(var.name, count.index)
  cloud_init = var.cloud_init
  private_network {
    pn_id = var.network_id
  }
  root_volume {
    size_in_gb = 160
  }
}

resource "scaleway_vpc_public_gateway_dhcp_reservation" "main" {
  gateway_network_id = var.gateway_id
  mac_address        = scaleway_instance_server.virtual_machine[count.index].private_network.0.mac_address
  ip_address         = "192.168.1.${count.index + var.start_ip}"
  count              = var.instances
  depends_on         = [scaleway_instance_server.virtual_machine]
}

data "scaleway_vpc_public_gateway_dhcp_reservation" "by_mac_address" {
  count       = var.instances
  mac_address = scaleway_instance_server.virtual_machine[count.index].private_network.0.mac_address
  depends_on  = [scaleway_vpc_public_gateway_dhcp_reservation.main]
}
