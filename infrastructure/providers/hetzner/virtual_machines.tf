resource "hcloud_ssh_key" "vm" {
  name       = format(module.common.name_format, local.location, "ssh")
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "hcloud_placement_group" "vm" {
  name = format(module.common.name_format, local.location, "kubernetes")
  type = "spread"
}

# Manager nodes may or may not run Gitpod resources
module "k3s_manager" {
  source = "./node"

  # cloud_init                = file("../../../cloud-init/k3s-manager.yaml")
  firewall        = hcloud_firewall.firewall.id
  instances       = local.deployment[var.size].machines.manager.count
  load_balancer   = hcloud_load_balancer.load_balancer.id
  location        = var.location
  name            = format(module.common.name_format, local.location, "k3s-manager-%s")
  network_id      = hcloud_network.network.id
  placement_group = hcloud_placement_group.vm.id
  server_type     = local.deployment[var.size].machines.manager.server_type
  ssh_key         = hcloud_ssh_key.vm.id
}

# Worker nodes are where the Gitpod resources run
module "k3s_nodes" {
  source = "./node"
  count  = length(local.deployment[var.size].machines.nodes)

  # cloud_init = templatefile("../../../cloud-init/k3s-node.yaml", {
  #   labels         = local.deployment[var.size].machines.nodes[count.index].labels
  #   join_token     = module.k3s_setup.k3s_token
  #   server_address = module.k3s_manager.nodes[0].private_ip
  # })
  firewall        = hcloud_firewall.firewall.id
  instances       = local.deployment[var.size].machines.nodes[count.index].count
  load_balancer   = hcloud_load_balancer.load_balancer.id
  location        = var.location
  name            = format(module.common.name_format, local.location, "k3s-node-${count.index}-%s")
  network_id      = hcloud_network.network.id
  placement_group = hcloud_placement_group.vm.id
  server_type     = local.deployment[var.size].machines.nodes[count.index].server_type
  ssh_key         = hcloud_ssh_key.vm.id
}

# The servers aren't immediately available when started
resource "time_sleep" "managers" {
  depends_on = [
    module.k3s_manager,
  ]

  create_duration = "30s"
}
resource "time_sleep" "nodes" {
  depends_on = [
    module.k3s_nodes,
  ]

  create_duration = "30s"
}

module "k3s_setup" {
  source = "../../modules/k3s"

  managers = [for node in module.k3s_manager.nodes : {
    node        = node
    labels      = local.deployment[var.size].machines.manager.labels
    private_key = local.vm_private_key
  }]
}
