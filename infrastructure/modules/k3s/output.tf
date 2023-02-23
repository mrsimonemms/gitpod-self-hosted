output "firewall_ports" {
  value = module.common.firewall_ports
}

output "k3s_token" {
  value     = local.k3s_token
  sensitive = true
}

output "kubeconfig" {
  value     = ssh_sensitive_resource.kubeconfig.result
  sensitive = true
}

output "kubecontext" {
  value = var.kubecontext
}
