# Grants the environment's system-assigned identity read access to the Key Vault holding the
# certificate secret. Only created when kv_config is supplied.
resource "azurerm_role_assignment" "kv_secret_operator" {
  count                = local.enable_kv_secret_role_assignment ? 1 : 0
  scope                = var.kv_config.kv_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app_environment.this.identity[0].principal_id
}
