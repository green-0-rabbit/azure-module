output "id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "administrator_login" {
  description = "The administrator login of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}

output "database_names" {
  description = "Names of databases created."
  value       = [for db in azurerm_postgresql_flexible_server_database.this : db.name]
}

output "database_ids" {
  description = "Map of created databases by name to resource ID."
  value       = { for name, db in azurerm_postgresql_flexible_server_database.this : name => db.id }
}

output "private_endpoint_id" {
  description = "Private endpoint ID (if enabled)"
  value       = try(azurerm_private_endpoint.pgflex_pe[0].id, null)
}

output "private_endpoint_ip" {
  description = "Private endpoint IP address (if enabled and statically configured)"
  value = lookup(
    { for cfg in try(azurerm_private_endpoint.pgflex_pe[0].ip_configuration, []) : cfg.name => cfg.private_ip_address },
    local.pep_ip_config_name,
    null
  )
}
