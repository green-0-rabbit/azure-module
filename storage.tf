module "storage" {
  source = "../../storageaccount"

  storage_account_name          = var.storage_account_name
  env                           = var.env
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  public_network_access_enabled = false

  # Private endpoint via module built-in support
  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    dns_id             = azurerm_private_dns_zone.blob.id
  }

  tags = var.tags
}

resource "azurerm_storage_container" "todo" {
  name                  = var.storage_container_name
  storage_account_id    = module.storage.id
  container_access_type = "private"
}
