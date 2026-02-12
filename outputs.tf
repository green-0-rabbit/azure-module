output "app_id" { value = azurerm_container_app.app.id }
output "app_name" { value = azurerm_container_app.app.name }
# For internal ingress, Azure still provides an FQDN that resolves privately in the VNet
output "app_fqdn" { value = try(azurerm_container_app.app.ingress[0].fqdn, null) }
output "principal_id" {
  value       = azurerm_user_assigned_identity.aca_identity.principal_id
  description = "The Principal ID of the module-managed User Assigned Identity."
}
