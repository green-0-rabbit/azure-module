locals {
  resource_name           = "${lower(var.storage_account_name)}-${var.env}"
  pep_subresource_name    = "blob"
  pep_member_name         = "default"
  pep_ip_config_name      = "sa-pe-ip-config"
  pep_prefix              = "sa"
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
}
