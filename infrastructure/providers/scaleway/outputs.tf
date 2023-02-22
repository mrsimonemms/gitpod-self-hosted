output "dns_records" {
  value = [
    {
      type      = "A"
      name      = "${var.subdomain}.${var.domain_name}"
      subdomain = var.subdomain
      value     = scaleway_lb_ip.main.ip_address
    },
    {
      type      = "A"
      name      = "*.${var.subdomain}.${var.domain_name}"
      subdomain = "*.${var.subdomain}"
      value     = scaleway_lb_ip.main.ip_address
    },
    {
      type      = "A"
      name      = "*.ws.${var.subdomain}.${var.domain_name}"
      subdomain = "*.ws.${var.subdomain}"
      value     = scaleway_lb_ip.main.ip_address
    },
  ]
}

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.k3s_setup.kubeconfig
  sensitive   = true
}
