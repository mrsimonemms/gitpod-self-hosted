resource "azurerm_public_ip" "node" {
  count = var.instances

  name                = format(var.name, count.index)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "node" {
  count = var.instances

  name                = format(var.name, count.index)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.node[count.index].id
  }
}
resource "azurerm_network_interface_security_group_association" "node" {
  count = var.instances

  network_interface_id      = azurerm_network_interface.node[count.index].id
  network_security_group_id = var.network_security_group_id
}

# Associate the network interface to a load balancer pool
resource "azurerm_network_interface_backend_address_pool_association" "node" {
  count = var.instances

  network_interface_id    = azurerm_network_interface.node[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.load_balancer_pool_id
}
