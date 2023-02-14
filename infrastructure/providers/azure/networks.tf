resource "azurerm_virtual_network" "network" {
  name                = format(module.common.name_format, local.location, "network")
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "network" {
  name                 = format(module.common.name_format, local.location, "network")
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_network_security_group" "network" {
  name                = format(module.common.name_format, local.location, "network")
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "network" {
  count = length(module.k3s_setup.firewall_ports)

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network.name

  priority  = sum([100, count.index])
  name      = replace(title(module.k3s_setup.firewall_ports[count.index].name), "/\\W/", "") # Remove any non-word characters
  access    = "Allow"
  direction = "Inbound"
  protocol  = title(lower(module.k3s_setup.firewall_ports[count.index].protocol))

  description                = module.k3s_setup.firewall_ports[count.index].name
  source_port_range          = "*"
  destination_port_range     = module.k3s_setup.firewall_ports[count.index].start == module.k3s_setup.firewall_ports[count.index].end ? module.k3s_setup.firewall_ports[count.index].start : "${module.k3s_setup.firewall_ports[count.index].start}-${module.k3s_setup.firewall_ports[count.index].end}"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}
