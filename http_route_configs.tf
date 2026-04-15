resource "azapi_resource" "http_route_config" {
  for_each = local.http_route_configs

  type                      = "Microsoft.App/managedEnvironments/httpRouteConfigs@2024-10-02-preview"
  name                      = each.key
  parent_id                 = azurerm_container_app_environment.this.id
  schema_validation_enabled = false
  ignore_null_property      = true
  response_export_values = {
    fqdn = "properties.fqdn"
  }

  body = {
    properties = {
      customDomains = [
        for custom_domain in each.value.custom_domains : {
          name          = custom_domain.name
          bindingType   = custom_domain.binding_type
          certificateId = try(custom_domain.certificate_id, null)
        }
      ]
      rules = [
        for rule in each.value.rules : {
          description = try(rule.description, null)
          routes = [
            for route in rule.routes : {
              match = {
                path                = try(route.match.path, null)
                prefix              = try(route.match.prefix, null)
                pathSeparatedPrefix = try(route.match.path_separated_prefix, null)
                caseSensitive       = try(route.match.case_sensitive, null)
              }
              action = try(route.action, null) == null ? null : {
                prefixRewrite = try(route.action.prefix_rewrite, null)
              }
            }
          ]
          targets = [
            for target in rule.targets : {
              containerApp = target.container_app
              label        = try(target.label, null)
              revision     = try(target.revision, null)
              weight       = try(target.weight, null)
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    azurerm_container_app_environment.this,
    azurerm_container_app_environment_certificate.this,
  ]
}