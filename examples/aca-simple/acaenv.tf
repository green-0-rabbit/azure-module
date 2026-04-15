module "container_app_environment" {
  source = "../../acaenv"

  name                               = "${var.project}-acaenv-${var.env}"
  env                                = var.env
  location                           = var.location
  resource_group_name                = azurerm_resource_group.rg.name
  infrastructure_subnet_id           = module.vnet_spoke.subnet_ids["ACASubnet"]
  infrastructure_resource_group_name = "aca-private-${var.env}-rg"

  logs_destination = "none"

  workload_profile = {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  networking = {
    subnet_id = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
  }

  dns = {
    register_pe_to_dns = true
    dns_id             = azurerm_private_dns_zone.aca.id
  }

  certificate_config = nonsensitive(var.route_custom_domain_certificate_blob_base64) != "" ? {
    name                    = "${local.route_config_name}-cert-${var.env}"
    certificate_blob_base64 = var.route_custom_domain_certificate_blob_base64
    certificate_password    = var.route_custom_domain_certificate_password
  } : null

  http_route_configs = {
    (local.route_config_name) = {
      custom_domains = (
        var.route_custom_domain_name != ""
        && nonsensitive(var.route_custom_domain_certificate_blob_base64) != ""
      ) ? [
        {
          name         = var.route_custom_domain_name
          binding_type = "SniEnabled"
        }
      ] : []
      rules = [
        {
          description = "Route frontend requests by prefix"
          routes = [
            {
              match = {
                prefix = "/frontend"
              }
              action = {
                prefix_rewrite = "/"
              }
            }
          ]
          targets = [
            {
              container_app = "${local.frontend_app_name}-${var.env}"
            }
          ]
        },
        {
          description = "Route showcase root by exact path"
          routes = [
            {
              match = {
                path = "/showcase"
              }
              action = {
                prefix_rewrite = "/"
              }
            },
            {
              match = {
                path_separated_prefix = "/sample"
              }
              action = {
                prefix_rewrite = "/"
              }
            }
          ]
          targets = [
            {
              container_app = "${local.showcase_app_name}-${var.env}"
            }
          ]
        }
      ]
    }
  }

  tags = var.tags
}
