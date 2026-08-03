module "vnet_spoke" {
  source = "../../vnet"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.spoke_vnet_name

  vnet_address_space = var.spoke_vnet_address_space

  # Both zone names are plan-time constants, which is what the module's for_each requires.
  private_dns_zone_resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_names = [
    azurerm_private_dns_zone.acr.name,
    azurerm_private_dns_zone.ase.name,
  ]

  subnets = var.spoke_vnet_subnets

  tags = var.tags
}
