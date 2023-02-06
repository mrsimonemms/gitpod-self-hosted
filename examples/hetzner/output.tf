output "cert_manager" {
  description = "cert-manager configuration"
  sensitive   = true
  value = {
    # Secrets required to make Cloudflare work
    secrets = {
      cloudflare-solver = {
        apiToken = var.cloudflare_api_token
      }
    }
    # ClusterIssuer configuration
    cluster_issuer = {
      spec = {
        acme = {
          solvers = [
            {
              dns01 = {
                cloudflare = {
                  apiTokenSecretRef = {
                    name = "cloudflare-solver"
                    key  = "apiToken"
                  }
                }
              }
            }
          ]
        }
      }
    }
  }
}

output "domain_name" {
  description = "The domain name Gitpod will be accessed on"
  value       = var.domain_name
}

output "gitpod_config" {
  description = "Gitpod config builder"
  value = {
    domain = var.domain_name
  }
}

output "gitpod_secrets" {
  description = "Gitpod config secrets"
  value       = {}
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.hetzner.kubeconfig
  sensitive   = true
}
