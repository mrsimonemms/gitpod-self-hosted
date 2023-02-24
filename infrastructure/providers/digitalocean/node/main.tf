terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.26.0, < 3.0.0"
    }
  }
}

resource "digitalocean_droplet" "virtual_machine" {
  count = var.instances

  name   = format(var.name, count.index)
  image  = "ubuntu-20-04-x64"
  size   = var.server_type
  region = var.location

  user_data = var.cloud_init

  vpc_uuid = var.network_id
  ipv6     = false

  ssh_keys = [
    var.ssh_key
  ]

  tags = concat(
    [
      "terraform",
    ],
    var.labels
  )
}
