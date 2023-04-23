terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.26.0, < 3.0.0"
    }
  }
}

module "common" {
  source = "../../modules/common"
}
