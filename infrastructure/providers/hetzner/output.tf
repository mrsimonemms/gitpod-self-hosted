output "kubeconfig" {
  value     = module.k3s_setup.kubeconfig
  sensitive = true
}
