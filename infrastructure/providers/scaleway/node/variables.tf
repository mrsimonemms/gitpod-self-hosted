variable "cloud_init" {
  default = null
}
variable "gateway_id" {}
variable "instances" {
  type    = number
  default = 1
}
variable "ip_group" {
  type = number
}
variable "name" {}
variable "network_id" {}
variable "security_group_id" {}
variable "server_type" {}
