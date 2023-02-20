terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.43.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "common" {
  source = "../../modules/common"
}
