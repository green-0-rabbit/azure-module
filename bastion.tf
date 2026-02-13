resource "azurerm_bastion_host" "devbox_bastion" {
  count               = var.enable_bastion_host ? 1 : 0
  name                = coalesce(var.bastion_name, "${var.vm_name}-bastion")
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                = "Developer"
  virtual_network_id = local.networking.virtual_network_id

  lifecycle {
    precondition {
      condition     = local.networking.virtual_network_id != null && length(local.networking.virtual_network_id) > 0
      error_message = "networking.virtual_network_id is required (or legacy virtual_network_id) when enable_bastion_host is true."
    }
  }
}
