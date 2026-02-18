module "keyvault" {
  source = "../../keyvault"

  key_vault_name                = var.key_vault_name
  env                           = var.env
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  public_network_access_enabled = true

  network_acls = {
    default_action             = "Deny"
    bypass                     = "None"
    ip_rules                   = var.key_vault_allowed_ip_ranges
    virtual_network_subnet_ids = []
  }

  # Private endpoint via module built-in support
  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    dns_id             = azurerm_private_dns_zone.keyvault.id
  }

  tags = var.tags
}
