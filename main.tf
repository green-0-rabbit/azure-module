resource "azurerm_resource_group" "rg" {
  name     = "aca-simple-${var.rg_prefix}-resource-group"
  location = var.location

  tags = {
    env = var.rg_prefix
  }
}