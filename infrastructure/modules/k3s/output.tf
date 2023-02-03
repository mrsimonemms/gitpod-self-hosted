output "k3s_token" {
  value     = local.k3s_token
  sensitive = true
}

output "kubeconfig" {
  value     = ssh_resource.kubeconfig.result
  sensitive = true
}
