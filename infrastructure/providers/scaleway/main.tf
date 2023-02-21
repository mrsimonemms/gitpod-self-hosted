terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.10.0, < 3.0.0"
    }
  }
}

module "common" {
  source = "../../modules/common"
}

provider "scaleway" {
  zone       = var.zone
  region     = var.location
  project_id = var.project_id
}
