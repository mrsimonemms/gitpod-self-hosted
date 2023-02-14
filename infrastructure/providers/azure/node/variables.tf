// @todo(sje): implement auto scaling option
variable "auto_scale" {
  type    = bool
  default = false
}
variable "azurerm_user_assigned_identity_id" {}
variable "cloud_init" {
  default = null
}
variable "instances" {
  type    = number
  default = 1
}
variable "load_balancer_pool_id" {}
variable "location" {}
variable "name" {}
variable "network_security_group_id" {}
variable "resource_group_name" {}
variable "server_type" {}
variable "ssh_key" {}
variable "subnet_id" {}
variable "vm_username" {}
