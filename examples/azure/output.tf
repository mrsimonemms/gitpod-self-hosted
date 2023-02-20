output "cert_manager" {
  description = "cert-manager configuration"
  sensitive   = true
  value = {
    # Secrets required to make AzureDNS work
    secrets = {}
    # AzureDNS configuration
    cluster_issuer = {
      spec = {
        acme = {
          solvers = [
            {
              dns01 = {
                azureDNS = {
                  hostedZoneName    = azurerm_dns_zone.gitpod.name
                  resourceGroupName = azurerm_resource_group.gitpod.name
                  subscriptionID    = data.azurerm_client_config.current.subscription_id
                  environment       = "AzurePublicCloud"
                  managedIdentity = {
                    clientID = azurerm_user_assigned_identity.cert_manager.client_id
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
    containerRegistry = {
      inCluster = false
      external = {
        url = azurerm_container_registry.registry.login_server
        certificate = {
          kind = "secret"
          name = "container-registry"
        }
      }
    }
    domain = var.domain_name
    database = {
      inCluster = false
      external = {
        certificate = {
          kind = "secret"
          name = "database"
        }
      }
      ssl = {
        caCert = {
          kind = "secret"
          name = "database-cacert"
        }
      }
    }
  }
}

output "gitpod_secrets" {
  description = "Gitpod config secrets"
  value = {
    container-registry = {
      ".dockerconfigjson" = jsonencode({
        auths = {
          "${azurerm_container_registry.registry.login_server}" = {
            username = azurerm_container_registry.registry.admin_username
            password = azurerm_container_registry.registry.admin_password
            auth     = base64encode("${azurerm_container_registry.registry.admin_username}:${azurerm_container_registry.registry.admin_password}")
          }
        }
      })
    }
    database = {
      encryptionKeys = "[{\"name\":\"general\",\"version\":1,\"primary\":true,\"material\":\"4uGh1q8y2DYryJwrVMHs0kWXJlqvHWWt/KJuNi04edI=\"}]"
      host           = "${azurerm_mysql_server.db.name}.mysql.database.azure.com"
      password       = azurerm_mysql_server.db.administrator_login_password
      port           = 3306
      username       = "${azurerm_mysql_server.db.administrator_login}@${azurerm_mysql_server.db.name}"
    }
    database-cacert = {
      # Downloaded CA cert from Azure
      # @link https://learn.microsoft.com/en-gb/azure/mysql/single-server/concepts-ssl-connection-security
      "ca.crt" = file("./mysql-ssl.crt.pem")
    }
  }
  sensitive = true
}

output "kubeconfig" {
  description = "Kubernetes config YAML file"
  value       = module.azure.kubeconfig
  sensitive   = true
}

output "kubecontext" {
  description = "Kubecontext name to use"
  value       = module.azure.kubecontext
}
