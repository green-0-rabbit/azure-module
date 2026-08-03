# The app is only reachable from inside the VNet, so this VM is how you verify it.
module "bastion_vm" {
  source = "../../bastion"

  project = var.project
  vm_size = "Standard_B1s"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_id             = module.vnet_spoke.id
  subnet_id           = module.vnet_spoke.subnet_ids["BastionSubnet"]

  vm_name             = "vm-bastion-${var.env}"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  enable_public_ip    = true
  enable_bastion_host = false
}
