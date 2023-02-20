# This provisions a container registry which will
# be where Gitpod's workspace images will be stored
#
# This is the recommendation for the setup, but this
# is deliberately outside of the Gitpod configuration
# so is entirely customisable
resource "random_integer" "registry" {
  min = 10000
  max = 99999
}

resource "azurerm_container_registry" "registry" {
  name                = "gitpod${random_integer.registry.result}"
  resource_group_name = azurerm_resource_group.gitpod.name
  location            = azurerm_resource_group.gitpod.location
  admin_enabled       = true
  sku                 = "Premium"
}
