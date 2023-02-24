# Create a new SSH key
resource "digitalocean_ssh_key" "vm" {
  name       = format(module.common.name_format, local.location, "ssh")
  public_key = local.vm_public_key
}

resource "random_integer" "label_id" {
  min = 1000
  max = 9999
}

locals {
  node_label = "gitpod-${random_integer.label_id.result}"
}

# Manager nodes may or may not run Gitpod resources
module "k3s_manager" {
  source = "./node"

  cloud_init  = file("${path.module}/../../../cloud-init/k3s_manager.yaml")
  instances   = local.deployment[var.size].machines.manager.count
  labels      = [local.node_label]
  location    = var.location
  name        = format(module.common.name_format, local.location, "k3s-manager-%s")
  network_id  = digitalocean_vpc.network.id
  server_type = local.deployment[var.size].machines.manager.server_type
  ssh_key     = digitalocean_ssh_key.vm.id
}

# Worker nodes are where the Gitpod resources run
module "k3s_nodes" {
  source = "./node"
  count  = length(local.deployment[var.size].machines.nodes)

  cloud_init = templatefile("${path.module}/../../../cloud-init/k3s_node.yaml", {
    labels         = local.deployment[var.size].machines.nodes[count.index].labels
    join_token     = module.k3s_setup.k3s_token
    server_address = module.k3s_manager.nodes[0].private_ip
  })
  instances   = local.deployment[var.size].machines.nodes[count.index].count
  labels      = [local.node_label]
  location    = var.location
  name        = format(module.common.name_format, local.location, "k3s-node-${count.index}-%s")
  network_id  = digitalocean_vpc.network.id
  server_type = local.deployment[var.size].machines.nodes[count.index].server_type
  ssh_key     = digitalocean_ssh_key.vm.id
}

module "k3s_setup" {
  source = "../../modules/k3s"

  kubecontext = var.kubecontext
  managers = [for node in module.k3s_manager.nodes : {
    node        = node
    labels      = local.deployment[var.size].machines.manager.labels
    private_key = local.vm_private_key
  }]
}
