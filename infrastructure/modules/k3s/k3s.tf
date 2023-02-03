resource "ssh_resource" "install_primary_manager" {
  host        = local.primary_manager.node.public_ip
  user        = local.primary_manager.node.username
  private_key = local.primary_manager.private_key

  commands = [
    # Uninstall k3s in case we've tainted the resource - this is allowed to fail
    "k3s-uninstall.sh || true",
    # Install k3s with additional labels
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server ${length(local.additional_managers) > 0 ? "--cluster-init" : ""} ${join(" ", [for k, v in local.primary_manager.labels : "--node-label=${k}=${v}"])} --disable traefik --node-external-ip ${local.primary_manager.node.public_ip} --node-ip ${local.primary_manager.node.private_ip}\" sh -'"
  ]
}

// Only run on first manager node
resource "ssh_resource" "kubeconfig" {
  depends_on = [
    ssh_resource.install_primary_manager
  ]

  triggers = {
    always_run = timestamp()
  }

  host        = local.primary_manager.node.public_ip
  user        = local.primary_manager.node.username
  private_key = local.primary_manager.private_key

  commands = [
    "sudo sed \"s/127.0.0.1/${local.primary_manager.node.public_ip}/g\" /etc/rancher/k3s/k3s.yaml"
  ]
}

// Only run on first manager node
resource "ssh_resource" "k3s_token" {
  depends_on = [
    ssh_resource.install_primary_manager
  ]

  host        = local.primary_manager.node.public_ip
  user        = local.primary_manager.node.username
  private_key = local.primary_manager.private_key

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

  host        = local.additional_managers[count.index].node.public_ip
  user        = local.additional_managers[count.index].node.username
  private_key = local.additional_managers[count.index].private_key

  commands = [
    # Uninstall k3s in case we've tainted the resource - this is allowed to fail
    "k3s-uninstall.sh || true",
    # Install k3s with additional labels
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server ${join(" ", [for k, v in local.additional_managers[count.index].labels : "--node-label=${k}=${v}"])} --disable traefik --node-external-ip ${local.additional_managers[count.index].node.public_ip} --node-ip ${local.additional_managers[count.index].node.private_ip}\" K3S_URL=\"https://${local.primary_manager.node.private_ip}:6443\" K3S_TOKEN=\"${local.k3s_token}\" sh -'"
  ]
}
