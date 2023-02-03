# Connect the Hetzner instance to Cloudflare
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.0.0, < 4.0.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "gitpod" {
  count = length(module.hetzner.dns_records)

  zone_id = var.cloudflare_zone_id
  name    = module.hetzner.dns_records[count.index].name
  type    = module.hetzner.dns_records[count.index].type
  value   = module.hetzner.dns_records[count.index].value
  ttl     = 60 # Use a short TTL
}
