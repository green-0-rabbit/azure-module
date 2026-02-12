#########################################################
# Create private endpoint for AI Foundry
#########################################################
resource "azurerm_private_endpoint" "ai_foundry_pe" {
  count = local.enable_private_endpoint ? 1 : 0

  name                = "${local.pep_prefix}-pe-${local.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.networking.subnet_id

  private_service_connection {
    name                 = "${local.pep_prefix}-psc-${local.resource_name}"
    is_manual_connection = false
    #private_connection_resource_id = azurerm_cognitive_account.ai_foundry.id
    private_connection_resource_id = azapi_resource.ai_foundry.id
    subresource_names              = [local.pep_subresource_name]
  }

  dynamic "private_dns_zone_group" {
    for_each = local.dns.register_pe_to_dns ? [1] : []
    content {
      name                 = "${local.pep_prefix}-pe-dns-${local.resource_name}"
      private_dns_zone_ids = local.dns.ai_foundry_dns_ids
    }
  }

  # Cognitive Services Endpoint
  dynamic "ip_configuration" {
    for_each = local.networking.static_ip_address_allocation == true ? toset([1]) : toset([])
    content {
      name               = "cs-pe-ip-config"
      private_ip_address = local.networking.cognitive_services_pe_ip
      subresource_name   = local.pep_subresource_name
      member_name        = "default"
    }
  }

  # Open AI Endpoint
  dynamic "ip_configuration" {
    for_each = local.networking.static_ip_address_allocation == true ? toset([1]) : toset([])
    content {
      name               = "oai-pe-ip-config"
      private_ip_address = local.networking.openai_pe_ip
      subresource_name   = local.pep_subresource_name
      member_name        = "secondary"
    }
  }

  # Services Endpoint
  dynamic "ip_configuration" {
    for_each = local.networking.static_ip_address_allocation == true ? toset([1]) : toset([])
    content {
      name               = "services-pe-ip-config"
      private_ip_address = local.networking.services_pe_ip
      subresource_name   = local.pep_subresource_name
      member_name        = "third"
    }
  }
}
