#########################
# Network (NIC)
#########################

resource "azurerm_public_ip" "pip" {
  count               = local.networking.enable_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = coalesce(var.nic_name, "${var.vm_name}-nic")
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = local.networking.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.networking.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  }

  lifecycle {
    precondition {
      condition     = length(local.networking.subnet_id) > 0
      error_message = "networking.subnet_id is required (or legacy subnet_id) and must be non-empty."
    }
  }
}
