resource "ssh_resource" "install_primary_manager" {
  host         = local.primary_manager.node.public_ip
  user         = local.primary_manager.node.username
  private_key  = local.primary_manager.private_key
  port         = 2244


  bastion_host = lookup(local.primary_manager, "bastion_host", null)
  bastion_port = lookup(local.primary_manager, "bastion_port", null)
  bastion_user = lookup(local.primary_manager, "bastion_user", null)

  commands = compact([
    # Uninstall k3s in case we've tainted the resource - this is allowed to fail
    "k3s-uninstall.sh || true",
    # Install k3s with additional labels
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server ${length(local.additional_managers) > 0 ? "--cluster-init" : ""} ${join(" ", [for k, v in local.primary_manager.labels : "--node-label=${k}=${v}"])} --tls-san=${local.k3s_server_address_public} --disable traefik\" sh -'",
    # Disable scheduling to the node if multiple managers
    length(local.additional_managers) == 0 ? "" : "sudo kubectl taint nodes --overwrite $(hostname) app=gitpod-sh:NoSchedule",
  ])
}

// Only run on first manager node
resource "ssh_sensitive_resource" "kubeconfig" {
  depends_on = [
    ssh_resource.install_primary_manager
  ]

  triggers = {
    always_run = timestamp()
  }

  host         = local.primary_manager.node.public_ip
  user         = local.primary_manager.node.username
  private_key  = local.primary_manager.private_key
  bastion_host = local.primary_manager.bastion_host
  bastion_port = local.primary_manager.bastion_port
  bastion_user = local.primary_manager.bastion_user
  port         = 2244

  commands = [
    "sudo sed \"s/127.0.0.1/${local.k3s_server_address_public}/g\" /etc/rancher/k3s/k3s.yaml"
  ]
}

# Run against any manager
resource "ssh_sensitive_resource" "k3s_token" {
  depends_on = [
    ssh_resource.install_primary_manager
  ]

  host         = local.k3s_server_address_public
  user         = local.primary_manager.node.username
  private_key  = local.primary_manager.private_key
  port         = 2244

  bastion_host = lookup(local.primary_manager, "bastion_host", null)
  bastion_port = lookup(local.primary_manager, "bastion_port", null)
  bastion_user = lookup(local.primary_manager, "bastion_user", null)

  commands = [
    "sudo cat /var/lib/rancher/k3s/server/node-token"
  ]
}

// Install k3s on additional manager nodes
resource "ssh_resource" "install_additional_managers" {
  count = length(local.additional_managers)
  depends_on = [
    ssh_resource.install_primary_manager
  ]

  host         = local.additional_managers[count.index].node.public_ip
  user         = local.additional_managers[count.index].node.username
  private_key  = local.additional_managers[count.index].private_key
  port         = 2244

  bastion_host = lookup(local.additional_managers[count.index], "bastion_host", null)
  bastion_port = lookup(local.additional_managers[count.index], "bastion_port", null)
  bastion_user = lookup(local.additional_managers[count.index], "bastion_user", null)

  commands = [
    # Uninstall k3s in case we've tainted the resource - this is allowed to fail
    "k3s-uninstall.sh || true",
    # Install k3s with additional labels
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server ${join(" ", [for k, v in local.additional_managers[count.index].labels : "--node-label=${k}=${v}"])} --disable traefik\" K3S_URL=\"https://${local.k3s_server_address_private}:6443\" K3S_TOKEN=\"${local.k3s_token}\" sh -'",
    # Disable scheduling to the node if multiple managers
    "sudo kubectl taint nodes --overwrite $(hostname) app=gitpod-sh:NoSchedule",
  ]
}
