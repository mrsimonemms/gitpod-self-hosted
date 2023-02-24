output "dns_records" {
  value = [
    {
      type      = "A"
      name      = var.domain_name
      subdomain = "@"
      value     = digitalocean_loadbalancer.load_balancer.ip
    },
    {
      type      = "A"
      name      = "*.${var.domain_name}"
      subdomain = "*."
      value     = digitalocean_loadbalancer.load_balancer.ip
    },
    {
      type      = "A"
      name      = "*.ws.${var.domain_name}"
      subdomain = "*.ws"
      value     = digitalocean_loadbalancer.load_balancer.ip
    },
  ]
}

output "k3s_token" {
  description = "Join token for k3s"
  # value       = module.k3s_setup.k3s_token
  value     = ""
  sensitive = true
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
