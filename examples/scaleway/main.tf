
# Configure the infrastructure in Scaleway
module "scaleway" {
  source = "git@github.com:buggtb/gitpod-self-hosted.git//infrastructure/providers/scaleway?ref=feature/scaleway"

  domain_name          = var.domain_name
  size                 = var.size
  ssh_private_key_path = var.ssh_private_key_path
  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  subdomain            = var.subdomain
}
