output "id" {
  description = "Web app resource ID"
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "Web app name"
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default hostname assigned by Azure"
  value       = azurerm_linux_web_app.this.default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses used by the app"
  value       = azurerm_linux_web_app.this.outbound_ip_address_list
}

output "possible_outbound_ip_addresses" {
  description = "Every outbound IP the app could use, including those not currently in use"
  value       = azurerm_linux_web_app.this.possible_outbound_ip_address_list
}

output "principal_id" {
  description = "The Principal ID of the module-managed User Assigned Identity."
  value       = azurerm_user_assigned_identity.webapp_identity.principal_id
}

output "identity_name" {
  description = "The name of the module-managed User Assigned Identity."
  value       = azurerm_user_assigned_identity.webapp_identity.name
}

output "identity_client_id" {
  description = "The client ID of the module-managed User Assigned Identity."
  value       = azurerm_user_assigned_identity.webapp_identity.client_id
}

output "identity_id" {
  description = "The resource ID of the module-managed User Assigned Identity."
  value       = azurerm_user_assigned_identity.webapp_identity.id
}

output "private_endpoint_id" {
  description = "Private endpoint ID (if enabled)"
  value       = try(azurerm_private_endpoint.webapp_pe[0].id, null)
}

output "private_endpoint_ip" {
  description = "Private endpoint IP address (if enabled and statically configured)"
  value = lookup(
    { for cfg in try(azurerm_private_endpoint.webapp_pe[0].ip_configuration, []) : cfg.name => cfg.private_ip_address },
    local.pep_ip_config_name,
    null
  )
}
