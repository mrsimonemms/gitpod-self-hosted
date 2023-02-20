# This provisions a MySQL 5.7 instance which will be
# where Gitpod stores its' data
#
# This is outside the provider configuration so it's
# entirely customisable to your needs, so long as it
# is MySQL 5.7.
#
# This example connects over SSL to demonstrate how
# that can be achieved.
resource "random_integer" "db" {
  min = 10000
  max = 99999
}

resource "random_password" "db" {
  length = 32
}

resource "azurerm_mysql_server" "db" {
  name                = "gitpod-${random_integer.db.result}"
  location            = azurerm_resource_group.gitpod.location
  resource_group_name = azurerm_resource_group.gitpod.name

  sku_name                         = "GP_Gen5_2"
  storage_mb                       = 20480
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  version                          = "5.7"

  auto_grow_enabled            = true
  administrator_login          = "gitpod" # Must be "gitpod"
  administrator_login_password = random_password.db.result
}

resource "azurerm_mysql_firewall_rule" "db" {
  name                = "Azure_Resource"
  resource_group_name = azurerm_resource_group.gitpod.name
  server_name         = azurerm_mysql_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_database" "db" {
  name                = "gitpod"
  resource_group_name = azurerm_resource_group.gitpod.name
  server_name         = azurerm_mysql_server.db.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
