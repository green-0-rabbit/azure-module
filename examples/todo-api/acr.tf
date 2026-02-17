module "acr" {
  source = "../../acr"

  acr_name            = var.acr_name
  env                 = var.env
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Premium"

  # Private endpoint
  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    dns_id             = azurerm_private_dns_zone.acr.id
  }

  tags = var.tags
}
