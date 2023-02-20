output "domain_name" {
  description = "The domain name Gitpod will be accessed on"
  value       = var.domain_name
  sensitive   = true
}

output "cert_manager" {
  description = "cert-manager configuration"
  sensitive   = true
  value = {
    # Secrets required to make Scaleway DNS work
    secrets = {}
    # Scaleway DNS configuration
    cluster_issuer = {
      spec = {
        acme = {
          solvers = [
            {
              dns01 = {
                webhook = {
                  groupName = "acme.scaleway.com"
                  solverName = "scaleway"
                  config = {
                    accessKeySecretRef = {
                      key = "SCW_ACCESS_KEY"
                      name = "scaleway-secret"
                    }
                    secretKeySecretRef = {
                      key = "SCW_SECRET_KEY"
                      name = "scaleway-secret"
                    }
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

output "gitpod_config" {
  description = "Gitpod config builder"
  value = {
    authProviders = [
      {
        kind = "secret"
        name = "public-gitlab"
      },
    ]
    blockNewUsers = {
      enabled  = length(var.domain_passlist) > 0
      passlist = var.domain_passlist
    }
    domain = var.subdomain == null ? "${var.domain_name}" : "${var.subdomain}.${var.domain_name}"
  }
  sensitive = true
}

output "gitpod_secrets" {
  description = "Gitpod config secrets"
  value = {
    public-github = {
      provider = {
        id   = "Public-GitHub"
        host = "github.com"
        type = "GitHub"
        oauth = {
          clientId     = var.auth_providers.github.client_id
          clientSecret = var.auth_providers.github.client_secret
          callBackUrl  = var.subdomain == null ? "https://${var.domain_name}/auth/github.com/callback" : "https://${var.subdomain}.${var.domain_name}/auth/github.com/callback"
          settingsUrl  = var.auth_providers.github.settings_url
        }
      }
    }
    public-gitlab = {
      provider = {
        id   = "Public-GitLab"
        host = "gitlab.com"
        type = "GitLab"
        oauth = {
          clientId     = var.auth_providers.gitlab.client_id
          clientSecret = var.auth_providers.gitlab.client_secret
          callBackUrl  = var.subdomain == null ? "https://${var.domain_name}/auth/gitlab.com/callback" : "https://${var.subdomain}.${var.domain_name}/auth/gitlab.com/callback"
          settingsUrl  = var.auth_providers.gitlab.settings_url
        }
      }
    }
  }
  sensitive = true
}

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.scaleway.kubeconfig
  sensitive   = true
}

output "tls-certificates" {
  description = "Config for TLS certificates"
  value = {
    dnsNames = [
        var.subdomain == null ? "${var.domain_name}" : "${var.subdomain}.${var.domain_name}",
        var.subdomain == null ? "*.${var.domain_name}" : "*.${var.subdomain}.${var.domain_name}",
        var.subdomain == null ? "*.ws.${var.domain_name}" : "*.ws.${var.subdomain}.${var.domain_name}",
    ],
    issuer = var.cert_issuer
  }
  sensitive = true
}
