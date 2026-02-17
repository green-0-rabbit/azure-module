locals {
  resource_name        = "${lower(var.app_name)}-${var.env}"
  pep_subresource_name = "account"
  pep_prefix           = "aif"

  enable_private_endpoint = var.networking != null && var.dns != null

  networking = var.networking != null ? var.networking : {
    subnet_id                    = ""
    static_ip_address_allocation = false
    cognitive_services_pe_ip     = null
    openai_pe_ip                 = null
    services_pe_ip               = null
  }

  dns = var.dns != null ? var.dns : {
    register_pe_to_dns = false
    ai_foundry_dns_ids = []
  }
}