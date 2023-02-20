output "nodes" {
  description = "Node information"
  value = [for index, vm in scaleway_instance_server.virtual_machine : {
    id                  = vm.id
    name                = vm.name
    public_ip           = vm.private_ip
    private_ip          = vm.private_ip
    username            = "ubuntu"
    dhcp_reservation_id = data.scaleway_vpc_public_gateway_dhcp_reservation.by_mac_address
  }]
}

output "reserved_ips" {
  description = "Reserved IPs for the nodes"
  value       = data.scaleway_vpc_public_gateway_dhcp_reservation.by_mac_address
}
