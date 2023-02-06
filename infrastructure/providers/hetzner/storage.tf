# Hetzner doesn't offer a managed database or storage, so
# we need to bring our own

resource "hcloud_server" "storage" {
  name        = format(module.common.name_format, local.location, "storage")
  server_type = "CX21"
  image       = "ubuntu-20.04"
  location    = var.location

  user_data = yamlencode({
    package_reboot_if_required = true
    package_update             = true
    package_upgrade            = true
    packages                   = []
    runcmd                     = []
    timezone                   = "UTC"
  })
}

resource "hcloud_volume" "storage" {
  name      = format(module.common.name_format, local.location, "storage")
  size      = 50
  server_id = hcloud_server.storage
  automount = true
  format    = "ext4"
}
