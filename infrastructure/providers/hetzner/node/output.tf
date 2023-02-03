output "nodes" {
  description = "Node information"
  value = [for vm in hcloud_server.virtual_machine : {
    id         = vm.id
    name       = vm.name
    public_ip  = vm.ipv4_address
    private_ip = try(one(vm.network[*].ip), vm.ipv4_address)
    username   = "root"
  }]
}
