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

output "identity_id" {
  description = "Resource ID of the user assigned identity attached to the app"
  value       = azurerm_user_assigned_identity.webapp_identity.id
}

output "identity_principal_id" {
  description = "Principal ID of the user assigned identity, for role assignments made outside this module"
  value       = azurerm_user_assigned_identity.webapp_identity.principal_id
}

output "identity_client_id" {
  description = "Client ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.webapp_identity.client_id
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
