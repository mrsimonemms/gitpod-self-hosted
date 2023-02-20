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

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.k3s_setup.kubeconfig
  sensitive   = true
}

output "network_security_group_id" {
  description = "Network security group the virtual machines are located in"
  value       = azurerm_network_security_group.network.id
}
