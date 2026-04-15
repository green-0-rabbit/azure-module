module "vnet_spoke" {
  source = "../../vnet"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.spoke_vnet_name

  vnet_address_space = var.spoke_vnet_address_space

  # Private DNS zones to link with this VNet
  private_dns_zone_resource_group_name = azurerm_resource_group.rg.name

  private_dns_zone_names = [
    azurerm_private_dns_zone.aca.name,
  ]

  subnets = var.spoke_vnet_subnets

  tags = {
    project-name = "${var.project}-${var.env}"
  }
}
