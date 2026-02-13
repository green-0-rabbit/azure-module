module "postgres" {
  source = "../../pgflexserver"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  server_name         = "psql-${var.env}-${var.project}"
  sku_name            = "B_Standard_B1ms"
  storage_mb          = 32768
  storage_tier        = "P4"
  postgres_version    = "17"
  zone                = "1"

  administrator_login    = var.postgres_administrator_login
  administrator_password = var.admin_password

  public_network_access_enabled = false

  databases = [
    { name = "todo_db" }
  ]

  # Private endpoint via module built-in support
  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    pgflex_dns_id      = azurerm_private_dns_zone.postgres.id
  }

  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "aad_admin" {
  server_name         = module.postgres.server_name
  resource_group_name = azurerm_resource_group.rg.name
  principal_name      = azurerm_user_assigned_identity.containerapp.name
  object_id           = azurerm_user_assigned_identity.containerapp.principal_id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  principal_type      = "ServicePrincipal"
}
