output "id" {
  value       = azurerm_container_registry.this.id
  description = "ACR resource ID"
}

output "name" {
  value       = azurerm_container_registry.this.name
  description = "ACR name"
}

output "login_server" {
  value       = azurerm_container_registry.this.login_server
  description = "ACR login server (e.g., <name>.azurecr.io)"
}

output "private_endpoint_ip" {
  value       = try(azurerm_private_endpoint.acr_pe[0].ip_configuration[0].private_ip_address, null)
  description = "Private endpoint IP address for ACR Private Link (if enabled)"
}
