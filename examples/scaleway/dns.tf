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

resource "scaleway_domain_record" "gitpod" {
  count = length(module.scaleway.dns_records)
  dns_zone = var.domain_name
  name     = module.scaleway.dns_records[count.index].subdomain
  type     = module.scaleway.dns_records[count.index].type
  data     = module.scaleway.dns_records[count.index].value
  ttl      = 60
}
