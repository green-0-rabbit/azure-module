locals {
  # required for ACR Private Link @see https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link#private-dns-zone  
  resource_name        = "${lower(var.acr_name)}-${var.env}"
  pep_subresource_name = "registry"
  pep_prefix           = "acr"

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