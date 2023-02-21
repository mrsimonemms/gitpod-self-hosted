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

# Configure the infrastructure in Scaleway
module "scaleway" {
  source = "../../infrastructure/providers/scaleway"

  domain_name          = var.domain_name
  kubecontext          = "gitpod-sh-scaleway"
  location             = var.location
  project_id           = var.project_id
  size                 = var.size
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path
  zone                 = var.zone
}
