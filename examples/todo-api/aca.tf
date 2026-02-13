locals {
  acr_login_server = module.acr.login_server
}

module "todo_app_api" {
  source = "../../aca"

  app_config = {
    name                         = "todo-app-api"
    revision_mode                = "Single"
    workload_profile_name        = module.container_app_environment.workload_profile_name
    container_app_environment_id = module.container_app_environment.id
  }
  environment         = var.env
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  acr_config = {
    registry_fqdn          = local.acr_login_server
    acr_id                 = module.acr.id
    create_role_assignment = true
  }

  kv_config = {
    kv_id                  = module.keyvault.id
    create_role_assignment = true
  }

  ingress = {
    external_enabled = true
    target_port      = var.app_port
    traffic_weight = [
      {
        latest_revision = true
        percentage      = 100
      }
    ]
  }

  secrets = [
    {
      name  = "database-password"
      value = var.admin_password
    }
  ]

  template = {
    min_replicas = 1
    max_replicas = 1
    containers = [
      {
        name   = "todo-app-api"
        image  = "humaapi0registry/todo-app-api:latest"
        cpu    = 0.5
        memory = "1Gi"
        env = [
          {
            name  = "PORT"
            value = var.app_port
          },
          {
            name  = "NODE_ENV"
            value = "prod"
          },
          # Database Configuration
          {
            name  = "DATABASE_HOST"
            value = module.postgres.fqdn
          },
          {
            name  = "DATABASE_PORT"
            value = "5432"
          },
          {
            name  = "DATABASE_SCHEMA"
            value = "todo_db"
          },
          {
            name  = "DATABASE_USERNAME"
            value = module.todo_app_api.identity_name
          },
          # Storage Configuration (Managed Identity)
          {
            name  = "AZURE_STORAGE_SERVICE_URI"
            value = module.storage.primary_blob_endpoint
          },
          {
            name  = "AZURE_STORAGE_CONTAINER_NAME"
            value = var.storage_container_name
          },
          {
            name  = "AZURE_CLIENT_ID"
            value = module.todo_app_api.identity_client_id
          },
          # AI Foundry Configuration (Managed Identity)
          {
            name  = "API_ENDPOINT"
            value = module.ai_foundry.openai_endpoint
          },
          {
            name  = "API_MODEL_NAME"
            value = "gpt-4.1-GlobalStandard"
          },
          {
            name  = "API_VERSION"
            value = "2024-10-21"
          },
        ]
      }
    ]
  }

  custom_domain = {
    name                     = "todo-api-${var.env}.${var.private_dns_zone_name}"
    certificate_id           = module.container_app_environment.certificate_id
    certificate_binding_type = "SniEnabled"
  }

  tags = var.tags
}
