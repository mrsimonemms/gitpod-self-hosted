output "nodes" {
  description = "Node information"
  value = [for vm in azurerm_linux_virtual_machine.node : {
    id         = vm.id
    name       = vm.name
    public_ip  = vm.public_ip_address
    private_ip = vm.private_ip_address
    username   = var.vm_username
  }]
}
