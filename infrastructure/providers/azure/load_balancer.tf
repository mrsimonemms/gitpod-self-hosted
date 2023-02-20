# Load balancer for Gitpod access
resource "azurerm_public_ip" "load_balancer" {
  name                = format(module.common.name_format, local.location, "lb")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = local.deployment[var.size].load_balancer
}

resource "azurerm_lb" "load_balancer" {
  name                = format(module.common.name_format, local.location, "lb")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.load_balancer.id
  }
}

locals {
  load_balancer_rules = [
    {
      name = "HTTP"
      port = 80
    },
    {
      name = "HTTPS"
      port = 443
    },
    {
      name = "SSH"
      port = 22
    },
  ]
}

resource "azurerm_lb_probe" "load_balancer" {
  count = length(local.load_balancer_rules)

  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = local.load_balancer_rules[count.index].name
  port            = local.load_balancer_rules[count.index].port
}

resource "azurerm_lb_rule" "load_balancer" {
  count = length(local.load_balancer_rules)

  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = local.load_balancer_rules[count.index].name
  protocol                       = "Tcp"
  frontend_port                  = local.load_balancer_rules[count.index].port
  backend_port                   = local.load_balancer_rules[count.index].port
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.load_balancer[count.index].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.load_balancer.id]
}

resource "azurerm_lb_backend_address_pool" "load_balancer" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = format(module.common.name_format, local.location, "lb")
}
