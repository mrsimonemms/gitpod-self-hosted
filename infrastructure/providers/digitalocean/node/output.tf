output "nodes" {
  description = "Node information"
  value = [for vm in digitalocean_droplet.virtual_machine : {
    id         = vm.id
    name       = vm.name
    public_ip  = vm.ipv4_address
    private_ip = vm.ipv4_address_private
    username   = "root"
  }]
}
