locals {
  resource_name                              = "${lower(var.name)}-${var.env}"
  infrastructure_resource_group_name_default = "aca-${local.resource_name}-rg"
  pep_subresource_name                       = "managedEnvironments"
  pep_member_name                            = "managedEnvironments"
  pep_ip_config_name                         = "acaenv-pe-ip-config"
  pep_prefix                                 = "acaenv"
  enable_private_endpoint                    = var.networking != null && var.dns != null

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
