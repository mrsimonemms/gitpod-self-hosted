terraform {
  # Use backend remote so we can use -backend-config argument when running terraform init
  backend "remote" {
    workspaces {
      prefix = "gitpod-sh-"
    }
  }
}

module "hetzner" {
  source = "../../infrastructure/providers/hetzner"

  domain_name = var.domain_name
  location    = var.location
  size        = var.size
}
