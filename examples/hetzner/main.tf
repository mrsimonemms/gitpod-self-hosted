# Configure the Terraform remote state
# @link https://developer.hashicorp.com/terraform/language/settings/backends/configuration
terraform {
  # Use backend remote so we can use -backend-config argument when running terraform init
  backend "remote" {
    workspaces {
      prefix = "gitpod-sh-"
    }
  }
}

# Configure the infrastructure in Hetzner
module "hetzner" {
  source = "../../infrastructure/providers/hetzner"

  domain_name          = var.domain_name
  location             = var.location
  size                 = var.size
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path
}
