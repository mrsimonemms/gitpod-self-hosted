variable "domain_name" {
  description = "The domain name Gitpod will be accessed on"
  type        = string
}

variable "location" {
  description = "Data centre location - run `az account list-locations -o table` for all available options"
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "Name of the resource group to locate all resources"
  type        = string
}

variable "size" {
  description = "Deployment size"
  type        = string
  default     = "small"
  validation {
    error_message = "Value must be small, medium or large"
    condition     = contains(["small"], var.size) // @todo(sje): support medium, large
  }
}

variable "size_data" {
  description = "Additional data for deployment size - this will be ignored if using an invalid 'size'"
  type        = object({})
  default     = {}
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

variable "azurerm_user_assigned_identity_id" {
  description = "Azure identity to associate with the node - this gives the virtual machines access to specific resources"
  type        = string
}
