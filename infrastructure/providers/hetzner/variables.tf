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
    condition     = contains(["small"], var.size) // @todo(sje): support medium and large
  }
}