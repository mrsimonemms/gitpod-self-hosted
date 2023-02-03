terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.0.0, < 2.0.0"
    }
  }
}

module "common" {
  source = "../../modules/common"
}

data "hcloud_location" "location" {
  name = var.location
}
