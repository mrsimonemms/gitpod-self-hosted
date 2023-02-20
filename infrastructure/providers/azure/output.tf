output "dns_records" {
  value = [
    {
      type      = "A"
      name      = var.domain_name
      subdomain = "@"
      value     = azurerm_public_ip.load_balancer.ip_address
    },
    {
      type      = "A"
      name      = "*.${var.domain_name}"
      subdomain = "*"
      value     = azurerm_public_ip.load_balancer.ip_address
    },
    {
      type      = "A"
      name      = "*.ws.${var.domain_name}"
      subdomain = "*.ws"
      value     = azurerm_public_ip.load_balancer.ip_address
    },
  ]
}

output "k3s_token" {
  description = "Join token for k3s"
  value       = module.k3s_setup.k3s_token
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.k3s_setup.kubeconfig
  sensitive   = true
}

output "kubecontext" {
  description = "Kubecontext name to use"
  value       = module.k3s_setup.kubecontext
}

output "network_security_group_id" {
  description = "Network security group the virtual machines are located in"
  value       = azurerm_network_security_group.network.id
}
