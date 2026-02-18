module "ai_foundry" {
  source = "../../aifoundry"

  app_name            = var.project
  env                 = var.env
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "AIServices"
  sku_name            = "S0"

  public_network_access_enabled = false

  models = {
    "gpt-4.1" = {
      version  = "2025-04-14"
      capacity = 50
      sku      = "GlobalStandard"
    }
  }

  # Private endpoint via module built-in support
  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    ai_foundry_dns_ids = values(azurerm_private_dns_zone.aifoundry)[*].id
  }

  tags = var.tags
}
