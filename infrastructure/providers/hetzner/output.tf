output "dns_records" {
  value = [
    {
      type      = "A"
      name      = var.domain_name
      subdomain = "@"
      value     = hcloud_load_balancer.load_balancer.ipv4
    },
    {
      type      = "A"
      name      = "*.${var.domain_name}"
      subdomain = "*."
      value     = hcloud_load_balancer.load_balancer.ipv4
    },
    {
      type      = "A"
      name      = "*.ws.${var.domain_name}"
      subdomain = "*.ws"
      value     = hcloud_load_balancer.load_balancer.ipv4
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
