// @todo(sje): implement auto scaling option
variable "auto_scale" {
  type    = bool
  default = false
}
variable "cloud_init" {
  default = null
}
# variable "firewall" {}
variable "instances" {
  type    = number
  default = 1
}
variable "labels" {
  type    = list(string)
  default = []
}
variable "location" {}
variable "name" {}
variable "network_id" {}
variable "server_type" {}
variable "ssh_key" {}
