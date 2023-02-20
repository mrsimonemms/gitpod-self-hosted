# Configure the Terraform remote state
# @link https://developer.hashicorp.com/terraform/language/settings/backends/configuration
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.0.0, < 4.0.0"
    }
  }

  # Values are set by environment variables in the Makefile
  # @link https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "gitpod" {
  name     = "gitpod-${terraform.workspace}"
  location = var.location
}

# Configure the infrastructure in Azure
module "azure" {
  source = "../../infrastructure/providers/azure"

  domain_name          = var.domain_name
  location             = azurerm_resource_group.gitpod.location
  size                 = var.size
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  azurerm_user_assigned_identity_id = azurerm_user_assigned_identity.cert_manager.id
  resource_group_name               = azurerm_resource_group.gitpod.name
}
