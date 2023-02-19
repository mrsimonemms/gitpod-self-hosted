locals {
  location = var.location
  deployment = {
    // Small is designed for a PoC or a personal Gitpod deployment - one manager, one node, no autoscaling
    small : {
      load_balancer = "lb11"
      machines = {
        // Manager is treated as a normal node - this is not ideal for production
        manager = {
          count = 1 // Single manager - this is not highly-available
          labels = {
            lookup(module.common.node_labels, "workload_meta")      = true
            lookup(module.common.node_labels, "workload_ide")       = true
            lookup(module.common.node_labels, "workspace_services") = true
            lookup(module.common.node_labels, "workspace_regular")  = true
            lookup(module.common.node_labels, "workspace_headless") = true
          }
          server_type = "cx41"
        },
        nodes = [
          {
            auto_scale = false // @todo(sje): work out how to autoscale
            count      = 1
            labels = {
              lookup(module.common.node_labels, "workload_meta")      = true
              lookup(module.common.node_labels, "workload_ide")       = true
              lookup(module.common.node_labels, "workspace_services") = true
              lookup(module.common.node_labels, "workspace_regular")  = true
              lookup(module.common.node_labels, "workspace_headless") = true
            }
            server_type = "cx41"
          },
        ]
      }
    },
    // Medium is designed for a few concurrent developers - highly-available manager, three Gitpod nodes, no autoscaling
    medium : {
      load_balancer = "lb11"
      machines = {
        // This manager won't run any Gitpod resources, just for Kubernetes management nodes
        manager = {
          count       = 3
          labels      = {}
          server_type = "cpx31"
        }
        nodes = [
          {
            auto_scale = false // @todo(sje): work out how to autoscale
            count      = var.size_data.node_count
            labels = {
              lookup(module.common.node_labels, "workload_meta")      = true
              lookup(module.common.node_labels, "workload_ide")       = true
              lookup(module.common.node_labels, "workspace_services") = true
              lookup(module.common.node_labels, "workspace_regular")  = true
              lookup(module.common.node_labels, "workspace_headless") = true
            }
            server_type = "cx41"
          },
        ]
      }
    },
    // @todo(sje): Large is designed for many concurrent developers - highly-available manager, autoscaling Gitpod nodes, multiple pools
    large : {},
  }
  vm_public_key  = file(var.ssh_public_key_path)
  vm_private_key = file(var.ssh_private_key_path)
  vm_username    = "gitpod"
}
