resource "scaleway_lb_ip" "main" {
}

resource "scaleway_lb" "main" {
  ip_id = scaleway_lb_ip.main.id
  name  = format(module.common.name_format, local.zone, "loadbalancer")
  type  = local.deployment[var.size].load_balancer

  private_network {
    private_network_id = scaleway_vpc_private_network.network.id
    dhcp_config        = true
  }

  depends_on = [scaleway_vpc_public_gateway.pg01]
}

resource "scaleway_lb_backend" "http-backend" {
  lb_id            = scaleway_lb.main.id
  name             = "http-backend"
  forward_protocol = "http"
  forward_port     = "80"
  server_ips       = concat([for i in module.k3s_manager.reserved_ips : i.ip_address], [for i in module.k3s_nodes : i.reserved_ips[0].ip_address])
}

resource "scaleway_lb_frontend" "http-frontend" {
  lb_id        = scaleway_lb.main.id
  backend_id   = scaleway_lb_backend.http-backend.id
  name         = "http-frontend"
  inbound_port = "80"
}

resource "scaleway_lb_backend" "https-backend" {
  lb_id            = scaleway_lb.main.id
  name             = "https-backend"
  forward_protocol = "tcp"
  forward_port     = "443"
  server_ips       = concat([for i in module.k3s_manager.reserved_ips : i.ip_address], [for i in module.k3s_nodes : i.reserved_ips[0].ip_address])
}

resource "scaleway_lb_frontend" "https-frontend" {
  lb_id        = scaleway_lb.main.id
  backend_id   = scaleway_lb_backend.https-backend.id
  name         = "https-frontend"
  inbound_port = "443"
}

resource "scaleway_lb_backend" "ssh-backend" {
  lb_id            = scaleway_lb.main.id
  name             = "ssh-backend"
  forward_protocol = "tcp"
  forward_port     = "22"
  server_ips       = concat([for i in module.k3s_manager.reserved_ips : i.ip_address], [for i in module.k3s_nodes : i.reserved_ips[0].ip_address])
}

resource "scaleway_lb_frontend" "ssh-frontend" {
  lb_id        = scaleway_lb.main.id
  backend_id   = scaleway_lb_backend.ssh-backend.id
  name         = "ssh-frontend"
  inbound_port = "22"
}

resource "scaleway_lb_backend" "kube-backend" {
  lb_id            = scaleway_lb.main.id
  name             = "kube-backend"
  forward_protocol = "tcp"
  forward_port     = "6443"
  server_ips       = [module.k3s_manager.reserved_ips[0].ip_address]
}

resource "scaleway_lb_frontend" "kube-frontend" {
  lb_id        = scaleway_lb.main.id
  backend_id   = scaleway_lb_backend.kube-backend.id
  name         = "kube-frontend"
  inbound_port = "6443"
}
