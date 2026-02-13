output "key_vault_id" {
  value       = module.keyvault.id
  description = "Key Vault ID."
}

output "storage_account_name" {
  value       = module.storage.name
  description = "Name of the storage account."
}

output "todo_api_fqdn" {
  value       = module.todo_app_api.app_fqdn
  description = "FQDN of the todo-api Container App."
}

output "container_app_environment_id" {
  value       = module.container_app_environment.id
  description = "ID of the Container App Environment."
}

### AI Foundry Outputs
output "ai_foundry_id" {
  value       = module.ai_foundry.ai_foundry_id
  description = "AI Foundry ID."
}

output "ai_foundry_name" {
  value       = module.ai_foundry.ai_foundry_name
  description = "AI Foundry Name."
}

### Postgres Outputs
output "postgres_fqdn" {
  value       = module.postgres.fqdn
  description = "FQDN of the PostgreSQL Flexible Server."
}

output "postgres_server_name" {
  value       = module.postgres.server_name
  description = "Name of the PostgreSQL Flexible Server."
}
