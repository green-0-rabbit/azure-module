output "ai_foundry_id" {
  description = "The resource ID of the AI Foundry account."
  value       = azapi_resource.ai_foundry.id
}

output "ai_foundry_name" {
  description = "The name of the AI Foundry account."
  value       = azapi_resource.ai_foundry.name
}

output "openai_endpoint" {
  description = "OpenAI endpoint for the AI Foundry account."
  value       = "https://aif-${local.resource_name}.openai.azure.com"
}

output "primary_access_key" {
  description = "The primary access key for the AI Foundry account."
  value       = data.azapi_resource_action.keys.output.key1
  sensitive   = true
}

output "cognitive_deployment_id" {
  value = { for k, v in azurerm_cognitive_deployment.aifoundry_deployment : k => v.id }
}

output "cognitive_services_private_endpoint_ip" {
  description = "Private endpoint IP for the Cognitive Services endpoint."
  value = lookup(
    { for cfg in try(azurerm_private_endpoint.ai_foundry_pe[0].ip_configuration, []) : cfg.name => cfg.private_ip_address },
    "cs-pe-ip-config",
    null
  )
}

output "openai_private_endpoint_ip" {
  description = "Private endpoint IP for the OpenAI endpoint."
  value = lookup(
    { for cfg in try(azurerm_private_endpoint.ai_foundry_pe[0].ip_configuration, []) : cfg.name => cfg.private_ip_address },
    "oai-pe-ip-config",
    null
  )
}

output "services_private_endpoint_ip" {
  description = "Private endpoint IP for the Services endpoint."
  value = lookup(
    { for cfg in try(azurerm_private_endpoint.ai_foundry_pe[0].ip_configuration, []) : cfg.name => cfg.private_ip_address },
    "services-pe-ip-config",
    null
  )
}