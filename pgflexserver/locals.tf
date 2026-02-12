locals {
  resource_name           = lower(var.server_name)
  pep_subresource_name    = "postgresqlServer"
  pep_member_name         = "postgresqlServer"
  pep_ip_config_name      = "pgflex-pe-ip-config"
  pep_prefix              = "pgflex"
  enable_private_endpoint = var.networking != null && var.dns != null

  networking = var.networking != null ? var.networking : {
    subnet_id                    = ""
    static_ip_address_allocation = false
    pe_ip                        = null
  }

  dns = var.dns != null ? var.dns : {
    register_pe_to_dns = false
    pgflex_dns_id      = null
  }
}
