terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  zone       = var.zone
  region     = var.region
  project_id = var.project_id
}


module "common" {
  source = "../../modules/common"
}
