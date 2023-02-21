# Common variables
variable "domain_name" {
  description = "The domain name Gitpod will be accessed on"
  type        = string
}

variable "location" {
  description = "Data centre location - this is dependent upon your provider"
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

variable "zone" {
  type        = string
  description = "The Scaleway zone"
  default     = "nl-ams-1"
}

## Specific to this deployment
variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Zone ID to place DNS records in"
  type        = string
}
