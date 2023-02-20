# Manager nodes may or may not run Gitpod resources
module "k3s_manager" {
  source = "./node"

  azurerm_user_assigned_identity_id = var.azurerm_user_assigned_identity_id
  cloud_init                        = file("${path.module}/../../../cloud-init/k3s_manager.yaml")
  instances                         = local.deployment[var.size].machines.manager.count
  load_balancer_pool_id             = azurerm_lb_backend_address_pool.load_balancer.id
  location                          = var.location
  name                              = format(module.common.name_format, local.location, "k3s-manager-%s")
  network_security_group_id         = azurerm_network_security_group.network.id
  resource_group_name               = var.resource_group_name
  server_type                       = local.deployment[var.size].machines.manager.server_type
  ssh_key                           = local.vm_public_key
  subnet_id                         = azurerm_subnet.network.id
  vm_username                       = local.vm_username
}

# Worker nodes are where the Gitpod resources run
module "k3s_nodes" {
  source = "./node"
  count  = length(local.deployment[var.size].machines.nodes)

  azurerm_user_assigned_identity_id = var.azurerm_user_assigned_identity_id
  cloud_init = templatefile("${path.module}/../../../cloud-init/k3s_node.yaml", {
    labels         = local.deployment[var.size].machines.nodes[count.index].labels
    join_token     = module.k3s_setup.k3s_token
    server_address = module.k3s_manager.nodes[0].private_ip
  })
  instances                 = local.deployment[var.size].machines.nodes[count.index].count
  load_balancer_pool_id     = azurerm_lb_backend_address_pool.load_balancer.id
  location                  = var.location
  name                      = format(module.common.name_format, local.location, "k3s-node-${count.index}-%s")
  network_security_group_id = azurerm_network_security_group.network.id
  resource_group_name       = var.resource_group_name
  server_type               = local.deployment[var.size].machines.nodes[count.index].server_type
  ssh_key                   = local.vm_public_key
  subnet_id                 = azurerm_subnet.network.id
  vm_username               = local.vm_username
}

module "k3s_setup" {
  source = "../../modules/k3s"

  managers = [for node in module.k3s_manager.nodes : {
    node        = node
    labels      = local.deployment[var.size].machines.manager.labels
    private_key = local.vm_private_key
  }]
}
