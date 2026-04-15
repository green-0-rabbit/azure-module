############################
# VM
############################
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.bastion.id]

  admin_username                  = var.admin_username
  disable_password_authentication = false
  admin_password                  = var.admin_password

  os_disk {
    name                 = coalesce(var.osdisk_name, "${var.vm_name}-osdisk")
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_sku
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  # Pass the computed FQDN into cloud-init
  custom_data = base64encode(
    templatefile("${path.module}/cloud-init.yml", {
    })
  )

  tags = var.tags

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

############################
# Disks
############################

resource "azurerm_managed_disk" "bastion_data" {
  name                 = coalesce(var.datadisk_name, "${var.vm_name}-data")
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disk_sku
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
}


resource "azurerm_virtual_machine_data_disk_attachment" "bastion" {
  managed_disk_id    = azurerm_managed_disk.bastion_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.bastion.id
  lun                = 0
  caching            = "ReadWrite"
}
