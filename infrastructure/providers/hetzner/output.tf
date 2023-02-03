output "dns_records" {
  value = [
    {
      type  = "A"
      name  = var.domain_name
      value = hcloud_load_balancer.load_balancer.ipv4
    },
    {
      type  = "A"
      name  = "*.${var.domain_name}"
      value = hcloud_load_balancer.load_balancer.ipv4
    },
    {
      type  = "A"
      name  = "*.ws.${var.domain_name}"
      value = hcloud_load_balancer.load_balancer.ipv4
    },
  ]
}

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.k3s_setup.kubeconfig
  sensitive   = true
}
