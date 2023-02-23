locals {
  additional_managers        = [for id, node in var.managers : node if id > 0]
  primary_manager            = var.managers[0] # There must be at least one manager
  k3s_server_address_public  = var.load_balancer_address == null ? local.primary_manager.node.public_ip : var.load_balancer_address
  k3s_server_address_private = var.load_balancer_address == null ? local.primary_manager.node.private_ip : var.load_balancer_address # Load balancer always uses a public address
  k3s_token                  = chomp(ssh_sensitive_resource.k3s_token.result)
  kubeconfig_address         = var.load_balancer_address != null ? var.load_balancer_address : (local.primary_manager.bastion_host != null ? local.primary_manager.bastion_host : local.primary_manager.node.public_ip)
  # https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/installation-requirements/port-requirements#ports-for-rancher-server-nodes-on-k3s
  tls_san_list = compact([
    local.k3s_server_address_public,
    lookup(local.primary_manager, "bastion_host", ""),
  ])
}
