variable "cloud_init" {
  default = null
}
variable "gateway_id" {}
variable "instances" {
  type    = number
  default = 1
}
variable "name" {}
variable "network_id" {}
variable "server_type" {}
variable "start_ip" {}
