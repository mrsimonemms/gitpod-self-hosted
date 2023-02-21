resource "scaleway_account_ssh_key" "vm" {
  name       = format(module.common.name_format, local.region, "ssh")
  public_key = local.vm_public_key
}

resource "random_integer" "label_id" {
  min = 1000
  max = 9999
}

locals {
  node_label = {
    load_balancer = "gitpod-${random_integer.label_id.result}"
  }
}

# Manager nodes may or may not run Gitpod resources
module "k3s_manager" {
  source = "./node"

  cloud_init  = file("${path.module}/../../../cloud-init/k3s_manager.yaml")
  instances   = local.deployment[var.size].machines.manager.count
  name        = format(module.common.name_format, local.region, "k3s-manager-%s")
  server_type = local.deployment[var.size].machines.manager.server_type
  network_id  = scaleway_vpc_private_network.network.id
  gateway_id  = scaleway_vpc_gateway_network.main.id
  start_ip    = 50
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
  name        = format(module.common.name_format, local.region, "k3s-node-${count.index}-%s")
  network_id  = scaleway_vpc_private_network.network.id
  server_type = local.deployment[var.size].machines.nodes[count.index].server_type
  gateway_id  = scaleway_vpc_gateway_network.main.id
  start_ip    = 60
}

resource "time_sleep" "managers" {
  depends_on = [
    module.k3s_manager,
  ]

  create_duration = "300s"
}

module "k3s_setup" {
  source = "../../modules/k3s"

  kubecontext = var.kubecontext
  managers = [for node in module.k3s_manager.nodes : {
    node                  = node
    labels                = local.deployment[var.size].machines.manager.labels
    private_key           = local.vm_private_key
    load_balancer_address = scaleway_lb_ip.main.ip_address

    bastion_host = scaleway_vpc_public_gateway_ip.gw01.address
    bastion_port = scaleway_vpc_public_gateway.pg01.bastion_port
    bastion_user = "bastion"
  }]

  depends_on = [time_sleep.managers]
}
