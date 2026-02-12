resource "azurerm_private_endpoint" "keyvault_pe" {
  count = local.enable_private_endpoint ? 1 : 0

  name                = "${local.pep_prefix}-pe-${local.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.networking.subnet_id

  private_service_connection {
    name                           = "${local.pep_prefix}-pl-${local.resource_name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = [local.pep_subresource_name]
  }

  dynamic "ip_configuration" {
    for_each = local.networking.static_ip_address_allocation == true ? toset([1]) : toset([])
    content {
      name               = local.pep_ip_config_name
      private_ip_address = local.networking.pe_ip
      subresource_name   = local.pep_subresource_name
      member_name        = local.pep_member_name
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = local.dns.register_pe_to_dns ? [1] : []
    content {
      name                 = "${local.pep_prefix}-pe-dns-${local.resource_name}"
      private_dns_zone_ids = compact([local.dns.dns_id])
    }
  }
}
