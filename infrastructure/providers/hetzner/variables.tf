variable "domain_name" {
  description = "The domain name Gitpod will be accessed on"
  type        = string
}

variable "location" {
  description = "Data centre location - see https://docs.hetzner.com/cloud/general/locations for all available options"
  type        = string
  default     = "nbg1"
}

variable "size" {
  description = "Deployment size"
  type        = string
  default     = "small"
  validation {
    error_message = "Value must be small, medium or large"
    condition     = contains(["small", "medium"], var.size) // @todo(sje): support large
  }
}

variable "size_data" {
  description = "Additional data for deployment size - this will be ignored if using an invalid 'size'"
  type = object({
    node_count = optional(number, 3)
  })
  default = {}
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
