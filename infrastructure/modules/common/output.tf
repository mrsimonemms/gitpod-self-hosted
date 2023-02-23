output "firewall_ports" {
  description = "Firewall ports for k3s"
  value       = local.firewall_ports
}

output "name_format" {
  description = "Name format to use for regional variables"
  value       = local.name_format
}

output "name_format_global" {
  description = "Name format to use for global variables"
  value       = local.name_format_global
}

output "node_labels" {
  description = "Labels to apply to nodes"
  value       = local.node_labels
}

output "workspace_name" {
  description = "Alphanumeric version of the namespace"
  value       = local.workspace_name
}
