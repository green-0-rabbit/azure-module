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

  http_route_configs = {
    for route_config_name, route_config in var.http_route_configs : route_config_name => merge(route_config, {
      custom_domains = [
        for custom_domain in route_config.custom_domains : merge(custom_domain, {
          certificate_id = coalesce(
            try(custom_domain.certificate_id, null),
            var.certificate_config != null ? azurerm_container_app_environment_certificate.this[0].id : null
          )
          binding_type = coalesce(
            try(custom_domain.binding_type, null),
            coalesce(
              try(custom_domain.certificate_id, null),
              var.certificate_config != null ? azurerm_container_app_environment_certificate.this[0].id : null
            ) != null ? "SniEnabled" : "Disabled"
          )
        })
      ]
    })
  }
}
