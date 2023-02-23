locals {
  // Ideally, this should come from the k3s module. Exists in here in case of circual dependencies
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
  name_format = join("-", [
    "gitpod",
    "%s", # region
    "%s", # name
    local.workspace_name
  ])
  name_format_global = join("-", [
    "gitpod",
    "%s", # name
    local.workspace_name
  ])
  node_labels = tomap({
    workload_meta : "gitpod.io/workload_meta"
    workload_ide : "gitpod.io/workload_ide"
    workspace_services : "gitpod.io/workload_services"
    workspace_regular : "gitpod.io/workload_workspace_regular"
    workspace_headless : "gitpod.io/workload_workspace_headless"
  })
  workspace_name = replace(terraform.workspace, "/[\\W\\-]/", "") # alphanumeric workspace name
}
