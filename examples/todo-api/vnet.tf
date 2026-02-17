module "vnet_spoke" {
  source = "../../vnet"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.spoke_vnet_name

  vnet_address_space = var.spoke_vnet_address_space

  # Private DNS zones to link with this VNet
  private_dns_zone_resource_group_name = azurerm_resource_group.rg.name

  private_dns_zone_names = concat(
    [
      azurerm_private_dns_zone.dev_zone.name,
      azurerm_private_dns_zone.keyvault.name,
      azurerm_private_dns_zone.blob.name,
      azurerm_private_dns_zone.acr.name,
      azurerm_private_dns_zone.postgres.name,
      azurerm_private_dns_zone.aca.name,
    ],
    values(azurerm_private_dns_zone.aifoundry)[*].name,
  )

  subnets = var.spoke_vnet_subnets

  tags = {
    project-name = "${var.project}-${var.env}"
  }
}
