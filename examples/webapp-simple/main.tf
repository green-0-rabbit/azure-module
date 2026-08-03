resource "azurerm_resource_group" "rg" {
  name     = "webapp-simple-${var.env}-resource-group"
  location = var.location

  tags = var.tags
}
