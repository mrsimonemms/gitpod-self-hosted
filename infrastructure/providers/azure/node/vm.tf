resource "azurerm_linux_virtual_machine" "node" {
  count = var.instances

  name                = format(var.name, count.index)
  size                = var.server_type
  location            = var.location
  resource_group_name = var.resource_group_name
  admin_username      = var.vm_username

  custom_data = base64encode(var.cloud_init)

  network_interface_ids = [
    azurerm_network_interface.node[count.index].id
  ]

  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.vm_username
    public_key = var.ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.azurerm_user_assigned_identity_id
    ]
  }

  lifecycle {
    ignore_changes = [
      custom_data,
    ]
  }
}
