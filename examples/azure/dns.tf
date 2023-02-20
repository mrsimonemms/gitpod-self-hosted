# Azure DNS zone creates a new subdomain which can be used
# as a nameserver
resource "azurerm_dns_zone" "gitpod" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.gitpod.name
}

resource "azurerm_dns_a_record" "gitpod" {
  count = length(module.azure.dns_records)

  zone_name           = azurerm_dns_zone.gitpod.name
  resource_group_name = azurerm_resource_group.gitpod.name
  name                = module.azure.dns_records[count.index].subdomain
  records             = [module.azure.dns_records[count.index].value]
  ttl                 = 60 # Use a short TTL
}

# Domain is hosted in Cloudflare which connects to the Azure
# DNS zone as a nameserver
#
# We only use about the first result as Terraform complains as
# it doesn't know the length of the list. This is usually (always?)
# 4 which provides redundancy, but in this example a single
# nameserver is enough
resource "cloudflare_record" "gitpod" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  type    = "NS"
  value   = tolist(azurerm_dns_zone.gitpod.name_servers).0
  ttl     = 60 # Use a short TTL
}

# Cert-manager needs an identity with access to the DNS Zone
# to create the ACME checks. This will be given to the virtual
# machines
#
# @link https://cert-manager.io/docs/configuration/acme/dns01/azuredns/
resource "random_integer" "cert_manager" {
  min = 10000
  max = 99999
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  name                = "gitpod-${random_integer.cert_manager.result}"
  location            = azurerm_resource_group.gitpod.location
  resource_group_name = azurerm_resource_group.gitpod.name
}

resource "azurerm_role_assignment" "cert_manager" {
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager.principal_id
  scope                = azurerm_dns_zone.gitpod.id
}
