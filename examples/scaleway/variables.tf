# Common variables
variable "domain_name" {
  description = "The domain name Gitpod will be accessed on"
  type        = string
  sensitive   = true
}

variable "subdomain" {

type = string

}

variable "size" {
  description = "Deployment size"
  type        = string
  default     = "small"

  validation {
    error_message = "Value must be small, medium or large"
    condition     = contains(["small", "medium"], var.size)
  }
}

# Specific variables
variable "zone" {

}

variable "project_id" {

}

variable "region" {

}
variable "ssh_public_key_path" {
  description = "Path to public key, used for logging in to VM - passphrases are not supported"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Path to private key, used for logging in to VM - passphrases are not supported"
  type        = string
  default     = "~/.ssh/id_rsa"
  sensitive   = true
}

variable "domain_passlist" {
  description = "Passlist for domains that are allowed to sign up to the instance"
  type        = list(string)
  default     = []
  sensitive   = true
}

variable "auth_providers" {
  description = "value"
  type = map(object({
    client_id     = string
    client_secret = string
    settings_url  = string
  }))
  default = {
    "github" = {
      client_id     = null
      client_secret = null
      settings_url  = null
    }
    "gitlab" = {
      client_id     = null
      client_secret = null
      settings_url  = null
    }
  }
  sensitive = true
}

variable "cert_issuer" {
  description = "The name of the kubernetes certificate issuer"
  type = string
  default = "my-scaleway-issuer"
  sensitive = true
}
