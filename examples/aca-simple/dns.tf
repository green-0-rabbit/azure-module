# Private DNS zone for Azure Container Apps
resource "azurerm_private_dns_zone" "aca" {
  name                = "privatelink.${var.location}.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.rg.name
}


