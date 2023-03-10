# Load balancer for Gitpod access
# This always exists
resource "hcloud_load_balancer" "load_balancer" {
  name               = format(module.common.name_format, local.location, "kubernetes")
  load_balancer_type = local.deployment[var.size].load_balancer
  location           = var.location
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "network_subnet" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = hcloud_network.network.id
}

resource "hcloud_load_balancer_target" "servers" {
  depends_on = [
    hcloud_load_balancer_network.network_subnet,
  ]

  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  label_selector   = join(",", [for key, value in local.node_label : "${key}=${value}"])
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "http"
  listen_port      = 80
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "tcp" # Use tcp not https as cert is generated by cluster
  listen_port      = 443
  destination_port = 443
}

resource "hcloud_load_balancer_service" "ssh" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "tcp"
  listen_port      = 22
  destination_port = 22
}

# Load balancer for Kubernetes manager pool
# Only create if more than one manager node

locals {
  k3s_load_balancer_count = local.deployment[var.size].machines.manager.count > 1 ? 1 : 0
}

resource "hcloud_load_balancer" "k3s_managers" {
  count = local.k3s_load_balancer_count

  name               = format(module.common.name_format, local.location, "k3s_manager")
  load_balancer_type = "lb11"
  location           = var.location
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "k3s_manager_subnet" {
  count = local.k3s_load_balancer_count

  load_balancer_id = hcloud_load_balancer.k3s_managers[count.index].id
  network_id       = hcloud_network.network.id
}

resource "hcloud_load_balancer_target" "k3s_managers" {
  count = local.k3s_load_balancer_count

  depends_on = [
    hcloud_load_balancer_network.k3s_manager_subnet,
  ]

  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.k3s_managers[count.index].id
  label_selector   = join(",", [for key, value in local.manager_label : "${key}=${value}"])
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "kubernetes" {
  count = local.k3s_load_balancer_count

  load_balancer_id = hcloud_load_balancer.k3s_managers[count.index].id
  protocol         = "tcp" # Use tcp not https as cert is generated by cluster
  listen_port      = 6443
  destination_port = 6443
}

resource "hcloud_load_balancer_service" "k3s_ssh" {
  count = local.k3s_load_balancer_count

  load_balancer_id = hcloud_load_balancer.k3s_managers[count.index].id
  protocol         = "tcp"
  listen_port      = 2244
  destination_port = 2244
}
