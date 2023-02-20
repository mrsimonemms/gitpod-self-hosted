variable "domain_name" {
  description = "The top level domain name Gitpod will be accessed on"
  type        = string
}
variable "subdomain" {
  description = "The subdomain, if any, Gitpod will be accessed on"
  type        = string
}

variable "region" {
  description = "Data centre location"
  type        = string
}

variable "zone" {
  type        = string
  description = "The Scaleway Zone"
}

variable "project_id" {
  type        = string
  description = "Your project ID."
}

variable "size" {
  description = "Deployment size"
  type        = string
  default     = "small"
  validation {
    error_message = "Value must be small, medium or large"
    condition     = contains(["small", "medium"], var.size) // @todo(sje): support medium and large
  }
}

variable "ssh_private_key_path" {
  description = "Path to private key, used for logging in to VM - passphrases are not supported. Needs to be registered with Scaleway for access."
  type        = string
  default     = "~/.ssh/id_rsa"
}
