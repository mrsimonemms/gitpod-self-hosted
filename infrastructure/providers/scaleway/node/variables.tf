variable "cloud_init" {
  default = null
}

variable "instances" {
  type    = number
  default = 1
}

variable "name" {}

variable "server_type" {}

variable "network_id" {}

variable "region" {
  description = "Data centre location"
  type        = string
  default     = ""
}

variable "gateway_id" {}

variable "start_ip" {}
