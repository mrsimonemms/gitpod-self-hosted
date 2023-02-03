locals {
  additional_managers = [for id, node in var.managers : node if id > 0]
  primary_manager     = var.managers[0] // There must be at least one manager
  k3s_token           = chomp(ssh_resource.k3s_token.result)
}
