module "keyvault" {
  source = "../../keyvault"

  key_vault_name      = var.key_vault_name
  env                 = var.env
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  # The module grants the caller Key Vault Administrator, which is a data plane role. Terraform
  # runs outside the VNet, so it needs the public endpoint to write the secret below. The app
  # still reads through the private endpoint, because the private DNS zone is linked to the VNet
  # and wins for anything resolving inside it. A real environment would keep this false and manage
  # secrets from inside the network.
  public_network_access_enabled = true
  rbac_authorization_enabled    = true

  # Demo settings: without these a destroyed vault lingers and blocks the name being reused.
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    dns_id             = azurerm_private_dns_zone.keyvault.id
  }

  tags = var.tags
}

# The value the app reads through its Key Vault reference. Written by Terraform, so it lands in
# state -- fine for a demo, but a real secret should be created outside Terraform.
resource "azurerm_key_vault_secret" "demo" {
  name         = var.demo_secret_name
  value        = "hello-from-key-vault"
  key_vault_id = module.keyvault.id
}
