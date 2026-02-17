module "devbox_windows_vm" {
  count  = var.enable_windows_devbox ? 1 : 0
  source = "../../devbox"

  project = var.project
  vm_size = var.windows_devbox_vm_size

  # Placement
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  networking = {
    subnet_id          = module.vnet_spoke.subnet_ids["MainSubnet"]
    virtual_network_id = module.vnet_spoke.id
  }

  # VM basics
  vm_name              = "vm-windevbox-${var.env}"
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  custom_image_id      = var.windows_devbox_custom_image_id
  enable_wsl_bootstrap = var.windows_devbox_enable_wsl_bootstrap

  # Marketplace fallback image (when custom_image_id is null)
  image_publisher = var.windows_devbox_image_publisher
  image_offer     = var.windows_devbox_image_offer
  image_sku       = var.windows_devbox_image_sku

  # Identity
  enable_managed_identity = true

  # Bastion (dedicated)
  enable_bastion_host = true
}
