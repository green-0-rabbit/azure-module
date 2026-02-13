#########################################################
# AI Foundry instance using Azapi
#########################################################
resource "azapi_resource_action" "purge_ai_foundry" {
  type        = "Microsoft.CognitiveServices/locations@2025-09-01"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.CognitiveServices/locations/${var.location}"
  action      = "resourceGroups/${var.resource_group_name}/deletedAccounts/aif-${local.resource_name}"
  method      = "DELETE"
  when        = "destroy"
}

# AI Foundry account (without network injection)
resource "azapi_resource" "ai_foundry" {
  type      = "Microsoft.CognitiveServices/accounts@2025-09-01"
  name      = "aif-${local.resource_name}"
  parent_id = data.azurerm_resource_group.target.id
  location  = var.location
  identity {
    type = "SystemAssigned"
  }
  schema_validation_enabled = false
  depends_on = [
    azapi_resource_action.purge_ai_foundry
  ]

  body = {
    kind = var.kind
    sku = {
      name = var.sku_name
    }

    properties = {
      # API properties
      apiProperties          = {}
      allowProjectManagement = true
      customSubDomainName    = "aif-${local.resource_name}"

      # Network-related controls (simplified without VNet injection)
      publicNetworkAccess = var.public_network_access_enabled ? "Enabled" : "Disabled"
    }
  }
}

data "azapi_resource_action" "keys" {
  type                   = "Microsoft.CognitiveServices/accounts@2025-09-01"
  resource_id            = azapi_resource.ai_foundry.id
  action                 = "listKeys"
  method                 = "POST"
  response_export_values = ["*"]
}

#########################################################
# Create a deployment for OpenAI's GPT-4o in the AI Foundry resource
#########################################################
resource "azurerm_cognitive_deployment" "aifoundry_deployment" {
  for_each = var.models
  name     = "${each.key}-${each.value.sku}"
  #cognitive_account_id = azurerm_cognitive_account.ai_foundry.id
  cognitive_account_id = azapi_resource.ai_foundry.id

  sku {
    name     = each.value.sku
    capacity = each.value.capacity
  }

  model {
    format  = each.value.format
    name    = each.key
    version = each.value.version
  }

  version_upgrade_option = "NoAutoUpgrade"
  rai_policy_name        = azurerm_cognitive_account_rai_policy.content_filter.name
  depends_on = [
    #azurerm_cognitive_account.ai_foundry
    azapi_resource.ai_foundry
  ]
}

#########################################################
# Apply content filtering to the model
#########################################################
resource "azurerm_cognitive_account_rai_policy" "content_filter" {
  name = "base_content_filter"
  #cognitive_account_id = azurerm_cognitive_account.ai_foundry.id
  cognitive_account_id = azapi_resource.ai_foundry.id
  base_policy_name     = "Microsoft.DefaultV2"

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "Violence"
    source             = "Prompt"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "Hate"
    source             = "Prompt"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "Sexual"
    source             = "Prompt"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "SelfHarm"
    source             = "Prompt"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "Violence"
    source             = "Completion"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "Hate"
    source             = "Completion"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "Sexual"
    source             = "Completion"
  }

  content_filter {
    severity_threshold = "High"
    block_enabled      = true
    filter_enabled     = true
    name               = "SelfHarm"
    source             = "Completion"
  }
}
