locals {
  azure_ai_private_dns_zones = toset([
    "privatelink.services.ai.azure.com",
    "privatelink.search.windows.net",
    "privatelink.openai.azure.com",
    "privatelink.cognitiveservices.azure.com",
  ])
}

# Custom backbone DNS zone
resource "azurerm_private_dns_zone" "dev_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

# Private DNS zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Private DNS zone for Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Private DNS zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Azure AI services DNS zones
resource "azurerm_private_dns_zone" "aifoundry" {
  for_each            = local.azure_ai_private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
}

# Private DNS zone for Azure Container Apps
resource "azurerm_private_dns_zone" "aca" {
  name                = "privatelink.${var.location}.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.rg.name
}

# Private DNS zone for ACR
resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}
