resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "uai-${local.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr_pull_uai" {
  count                = var.acr_config != null && try(var.acr_config.create_role_assignment, true) ? 1 : 0
  scope                = var.acr_config.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

resource "azurerm_role_assignment" "kv_pull_uai" {
  count                = var.kv_config != null && try(var.kv_config.create_role_assignment, true) ? 1 : 0
  scope                = var.kv_config.kv_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}
