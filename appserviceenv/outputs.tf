output "id" {
  description = "App Service Environment resource ID. Pass this to appserviceplan.app_service_environment_id."
  value       = azurerm_app_service_environment_v3.this.id
}

output "name" {
  description = "App Service Environment name"
  value       = azurerm_app_service_environment_v3.this.name
}

output "location" {
  description = "Region the environment was placed in, taken from the subnet"
  value       = azurerm_app_service_environment_v3.this.location
}

output "dns_suffix" {
  description = "DNS suffix for apps in this environment. An internal environment needs a private DNS zone of this name."
  value       = azurerm_app_service_environment_v3.this.dns_suffix
}

output "is_internal" {
  description = "Whether the environment uses an internal load balancer"
  value       = local.is_internal
}

output "internal_inbound_ip_addresses" {
  description = "Inbound IP addresses of an internal (ILB) environment. Empty when the environment is public."
  value       = azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses
}

output "external_inbound_ip_addresses" {
  description = "Inbound IP addresses of a public environment. Empty when the environment is internal."
  value       = azurerm_app_service_environment_v3.this.external_inbound_ip_addresses
}

output "linux_outbound_ip_addresses" {
  description = "Outbound IP addresses used by Linux apps in this environment"
  value       = azurerm_app_service_environment_v3.this.linux_outbound_ip_addresses
}

output "windows_outbound_ip_addresses" {
  description = "Outbound IP addresses used by Windows apps in this environment"
  value       = azurerm_app_service_environment_v3.this.windows_outbound_ip_addresses
}

output "pricing_tier" {
  description = "Pricing tier reported by Azure for the environment"
  value       = azurerm_app_service_environment_v3.this.pricing_tier
}
