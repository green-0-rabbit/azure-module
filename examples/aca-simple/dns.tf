# Private DNS zone for Azure Container Apps
resource "azurerm_private_dns_zone" "aca" {
  name                = "privatelink.${var.location}.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "custom_domain" {
  count               = var.private_dns_zone_name != "" ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}


