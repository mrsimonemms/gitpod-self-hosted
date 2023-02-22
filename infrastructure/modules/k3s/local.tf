locals {
  additional_managers        = [for id, node in var.managers : node if id > 0]
  primary_manager            = var.managers[0] # There must be at least one manager
  k3s_server_address_public  = var.load_balancer_address == null ? local.primary_manager.node.public_ip : var.load_balancer_address
  k3s_server_address_private = var.load_balancer_address == null ? local.primary_manager.node.private_ip : var.load_balancer_address # Load balancer always uses a public address
  k3s_token                  = chomp(ssh_sensitive_resource.k3s_token.result)
  kubeconfig_address         = var.load_balancer_address != null ? var.load_balancer_address : (local.primary_manager.bastion_host != null ? local.primary_manager.bastion_host : local.primary_manager.node.public_ip)
  # https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/installation-requirements/port-requirements#ports-for-rancher-server-nodes-on-k3s
  firewall_ports = [
    {
      name     = "Gitpod SSH"
      start    = 22
      end      = 22
      protocol = "TCP"
    },
    {
      name     = "SSH"
      start    = 2244
      end      = 2244
      protocol = "TCP"
    },
    {
      name     = "HTTP"
      start    = 80
      end      = 80
      protocol = "TCP"
    },
    {
      name     = "HTTPS"
      start    = 443
      end      = 443
      protocol = "TCP"
    },
    {
      name     = "Kubernetes"
      start    = 6443
      end      = 6443
      protocol = "TCP"
    },
    {
      name     = "k3s - etcd client requests"
      start    = 2379
      end      = 2380
      protocol = "TCP"
    },
    {
      name     = "k3s - Canal/Flannel VXLAN overlay networking"
      start    = 8472
      end      = 8472
      protocol = "UDP"
    },
    {
      name     = "k3s - Flannel UDP ports"
      start    = 51820
      end      = 51821
      protocol = "UDP"
    },
    {
      name     = "k3s - metrics server"
      start    = 10250
      end      = 10250
      protocol = "UDP"
    },
    {
      name     = "DNS"
      start    = 53
      end      = 53
      protocol = "TCP"
    },
    {
      name     = "DNS - UDP"
      start    = 53
      end      = 53
      protocol = "UDP"
    },
  ]
  tls_san_list = compact([
    local.k3s_server_address_public,
    lookup(local.primary_manager, "bastion_host", ""),
  ])
}
