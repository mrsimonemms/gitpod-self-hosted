# Load balancer for Gitpod access
# This always exists
resource "digitalocean_loadbalancer" "load_balancer" {
  name        = format(module.common.name_format, local.location, "kubernetes")
  size        = local.deployment[var.size].load_balancer
  region      = var.location
  algorithm   = "round_robin"
  droplet_tag = local.node_label
  vpc_uuid    = digitalocean_vpc.network.id

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "http2"

    target_port     = 443
    target_protocol = "http2"

    tls_passthrough = true
  }

  forwarding_rule {
    entry_port     = 22
    entry_protocol = "tcp"

    target_port     = 22
    target_protocol = "tcp"
  }

  healthcheck {
    port     = 443
    protocol = "tcp"
  }
}
