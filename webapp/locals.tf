locals {
  resource_name = "${lower(var.name)}-${var.env}"

  tags = merge({ "ResourceName" = local.resource_name }, var.tags)

  pep_subresource_name    = "sites"
  pep_member_name         = "sites"
  pep_ip_config_name      = "webapp-pe-ip-config"
  pep_prefix              = "webapp"
  enable_private_endpoint = var.networking != null && var.dns != null

  networking = var.networking != null ? var.networking : {
    subnet_id                    = ""
    static_ip_address_allocation = false
    pe_ip                        = null
  }

  dns = var.dns != null ? var.dns : {
    register_pe_to_dns = false
    dns_id             = null
  }

  # Pulling images from ACR with the app's identity needs both the flag and the client id, so
  # derive them together rather than making the caller keep the two in sync.
  use_acr_managed_identity = var.acr_config != null && try(var.acr_config.use_managed_identity, true)
}
