output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.hetzner.kubeconfig
  sensitive   = true
}
