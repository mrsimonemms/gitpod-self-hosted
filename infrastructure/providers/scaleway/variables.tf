variable "domain_name" {
  description = "The top level domain name Gitpod will be accessed on"
  type        = string
}

variable "kubecontext" {
  description = "Kubecontext name to use"
  default     = "gitpod-self-hosted"
}

variable "location" {
  description = "Data centre location - see https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/guides/regions_and_zones for all available options"
  type        = string
  default     = "nl-ams"
}

variable "project_id" {
  type        = string
  description = "Your project ID"
}

variable "size" {
  description = "Deployment size"
  type        = string
  default     = "small"
  validation {
    error_message = "Value must be small, medium or large"
    condition     = contains(["small"], var.size) // @todo(sje): support large
  }
}

variable "ssh_public_key_path" {
  description = "Path to public key, used for logging in to VM - passphrases are not supported"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to private key, used for logging in to VM - passphrases are not supported"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# variable "subdomain" {
#   description = "The subdomain, if any, Gitpod will be accessed on"
#   type        = string
# }

variable "zone" {
  type        = string
  description = "The Scaleway zone - see https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/guides/regions_and_zones for all available options"
  default     = "nl-ams-1"
}
