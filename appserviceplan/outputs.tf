output "id" {
  description = "App Service Plan resource ID"
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "App Service Plan name"
  value       = azurerm_service_plan.this.name
}

output "os_type" {
  description = "Operating system the plan was created for"
  value       = azurerm_service_plan.this.os_type
}

output "sku_name" {
  description = "SKU the plan runs on"
  value       = azurerm_service_plan.this.sku_name
}

output "worker_count" {
  description = "Number of workers allocated to the plan"
  value       = azurerm_service_plan.this.worker_count
}

output "app_service_environment_id" {
  description = "App Service Environment the plan sits inside, if any"
  value       = azurerm_service_plan.this.app_service_environment_id
}

output "kind" {
  description = "Plan kind as reported by Azure"
  value       = azurerm_service_plan.this.kind
}
