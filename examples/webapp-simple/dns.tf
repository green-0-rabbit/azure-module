# Private DNS zone for the ACR private endpoint.
resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

# Private DNS zone for the Key Vault private endpoint.
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

# An internal App Service Environment is only resolvable through a private DNS zone named after
# its DNS suffix. Azure does not create that zone, so it is created here.
#
# The name comes from local.ase_dns_suffix rather than module.app_service_environment.dns_suffix,
# because the vnet module links zones with for_each and for_each keys must be known at plan time.
# A computed attribute there fails with "Invalid for_each argument". Both zones are linked to the
# VNet through the module, in vnet.tf.
resource "azurerm_private_dns_zone" "ase" {
  name                = local.ase_dns_suffix
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

# Verifies the assumption above. Runs outside the resource graph, so referencing the environment
# here does not create a cycle with the vnet module.
check "ase_dns_suffix_matches" {
  assert {
    condition     = azurerm_private_dns_zone.ase.name == module.app_service_environment.dns_suffix
    error_message = "Private DNS zone ${azurerm_private_dns_zone.ase.name} does not match the environment's actual DNS suffix ${module.app_service_environment.dns_suffix}. Apps will not resolve. Check var.ase_domain_suffix for this cloud."
  }
}

locals {
  ase_ilb_ip = module.app_service_environment.internal_inbound_ip_addresses[0]
}

# Apps resolve as <app>.<dns_suffix>, the SCM endpoints as <app>.scm.<dns_suffix>, and the
# environment root is used by the platform itself. All three point at the ILB.
resource "azurerm_private_dns_a_record" "ase_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.ase.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [local.ase_ilb_ip]
}

resource "azurerm_private_dns_a_record" "ase_scm_wildcard" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.ase.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [local.ase_ilb_ip]
}

resource "azurerm_private_dns_a_record" "ase_root" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.ase.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [local.ase_ilb_ip]
}
