output "id" {
  value = azurerm_container_app_environment.this.id
}

output "name" {
  value = azurerm_container_app_environment.this.name
}

output "log_analytics_workspace_id" {
  value = var.log_analytics_workspace_id
}

output "workload_profile_name" {
  value = var.workload_profile.name
}

output "static_ip_address" {
  value = azurerm_container_app_environment.this.static_ip_address
}

output "certificate_id" {
  value = var.certificate_config != null ? azurerm_container_app_environment_certificate.this[0].id : null
}

output "http_route_config_ids" {
  description = "Environment-level HTTP route config resource IDs keyed by route config name."
  value       = { for name, config in azapi_resource.http_route_config : name => config.id }
}

output "http_route_config_names" {
  description = "Environment-level HTTP route config resource names keyed by route config name."
  value       = { for name, config in azapi_resource.http_route_config : name => config.name }
}

output "http_route_config_fqdns" {
  description = "Environment-level HTTP route config FQDNs keyed by route config name when returned by the Azure API."
  value       = { for name, config in azapi_resource.http_route_config : name => try(config.output.fqdn, null) }
}

output "logs_destination" {
  value = var.logs_destination
}

output "diagnostic_setting_id" {
  value = var.logs_destination == "azure-monitor" ? azurerm_monitor_diagnostic_setting.cae_to_law[0].id : null
}
output "default_domain" {
  value = azurerm_container_app_environment.this.default_domain
}

output "private_endpoint_id" {
  description = "Private endpoint ID (if enabled)"
  value       = try(azurerm_private_endpoint.acaenv_pe[0].id, null)
}

output "private_endpoint_ip" {
  description = "Private endpoint IP address (if enabled and statically configured)"
  value = lookup(
    { for cfg in try(azurerm_private_endpoint.acaenv_pe[0].ip_configuration, []) : cfg.name => cfg.private_ip_address },
    local.pep_ip_config_name,
    null
  )
}
