resource "hcloud_ssh_key" "vm" {
  name       = format(module.common.name_format, local.location, "ssh")
  public_key = local.vm_public_key
}

resource "hcloud_placement_group" "vm" {
  name = format(module.common.name_format, local.location, "kubernetes")
  type = "spread"
}

resource "random_integer" "label_id" {
  min = 1000
  max = 9999
}

locals {
  manager_label = {
    // If single manager node, connect to main load balancer, otherwise create it's own load balancer for manager nodes
    load_balancer = local.deployment[var.size].machines.manager.count == 1 ? "gitpod-${random_integer.label_id.result}" : "gitpod-manager-${random_integer.label_id.result}"
  }
  node_label = {
    load_balancer = "gitpod-${random_integer.label_id.result}"
  }
}

# Manager nodes may or may not run Gitpod resources
module "k3s_manager" {
  source = "./node"

  cloud_init      = file("${path.module}/../../../cloud-init/k3s_manager.yaml")
  firewall        = hcloud_firewall.firewall.id
  instances       = local.deployment[var.size].machines.manager.count
  labels          = local.manager_label
  location        = var.location
  name            = format(module.common.name_format, local.location, "k3s-manager-%s")
  network_id      = hcloud_network.network.id
  placement_group = hcloud_placement_group.vm.id
  server_type     = local.deployment[var.size].machines.manager.server_type
  ssh_key         = hcloud_ssh_key.vm.id
}

# The servers aren't immediately available when started
resource "time_sleep" "managers" {
  depends_on = [
    module.k3s_manager,
    hcloud_firewall.firewall,
  ]

  create_duration = "60s"
}

# Worker nodes are where the Gitpod resources run
module "k3s_nodes" {
  source = "./node"
  count  = length(local.deployment[var.size].machines.nodes)

  depends_on = [
    time_sleep.managers
  ]

  cloud_init = templatefile("${path.module}/../../../cloud-init/k3s_node.yaml", {
    labels         = local.deployment[var.size].machines.nodes[count.index].labels
    join_token     = module.k3s_setup.k3s_token
    server_address = local.deployment[var.size].machines.manager.count == 1 ? module.k3s_manager.nodes[0].private_ip : hcloud_load_balancer.k3s_managers.0.ipv4
  })
  firewall        = hcloud_firewall.firewall.id
  instances       = local.deployment[var.size].machines.nodes[count.index].count
  labels          = local.node_label
  location        = var.location
  name            = format(module.common.name_format, local.location, "k3s-node-${count.index}-%s")
  network_id      = hcloud_network.network.id
  placement_group = hcloud_placement_group.vm.id
  server_type     = local.deployment[var.size].machines.nodes[count.index].server_type
  ssh_key         = hcloud_ssh_key.vm.id
}

module "k3s_setup" {
  source                = "../../modules/k3s"
  kubecontext           = var.kubecontext
  load_balancer_address = local.deployment[var.size].machines.manager.count == 1 ? null : hcloud_load_balancer.k3s_managers.0.ipv4
  managers = [for node in module.k3s_manager.nodes : {
    node        = node
    labels      = local.deployment[var.size].machines.manager.labels
    private_key = local.vm_private_key
  }]
}
