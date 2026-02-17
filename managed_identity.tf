resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.todo_app_api.principal_id
}

resource "azurerm_role_assignment" "openai_user" {
  scope                = module.ai_foundry.ai_foundry_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.todo_app_api.principal_id
}
