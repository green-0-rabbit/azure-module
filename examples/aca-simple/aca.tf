locals {
  frontend_app_name = "frontend-app"
  showcase_app_name = "showcase-app"
  route_config_name = "approuter"
}

module "frontend_app" {
  source = "../../aca"

  app_config = {
    name                         = local.frontend_app_name
    revision_mode                = "Single"
    workload_profile_name        = module.container_app_environment.workload_profile_name
    container_app_environment_id = module.container_app_environment.id
  }
  environment         = var.env
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

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

  template = {
    min_replicas = 1
    max_replicas = 1
    containers = [
      {
        name   = local.frontend_app_name
        image  = "humaapi0registry/frontend-demo-fix:latest"
        cpu    = 0.5
        memory = "1Gi"
        env = [
          {
            name  = "API_URL"
            value = "https://mycustomdomain.com"
          },
          {
            name  = "SESSION_REPLAY_KEY"
            value = ""
          },
          {
            name  = "PIANO_ANALYTICS_SITE_ID"
            value = ""
          },
          {
            name  = "PIANO_ANALYTICS_COLLECTION_DOMAIN"
            value = ""
          }
        ]
      }
    ]
  }
}

module "showcase_app" {
  source = "../../aca"

  app_config = {
    name                         = local.showcase_app_name
    revision_mode                = "Single"
    workload_profile_name        = module.container_app_environment.workload_profile_name
    container_app_environment_id = module.container_app_environment.id
  }
  environment         = var.env
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ingress = {
    external_enabled = true
    target_port      = 80
    traffic_weight = [
      {
        latest_revision = true
        percentage      = 100
      }
    ]
  }

  template = {
    min_replicas = 1
    max_replicas = 1
    containers = [
      {
        name   = local.showcase_app_name
        image  = "mcr.microsoft.com/k8se/quickstart:latest"
        cpu    = 0.25
        memory = "0.5Gi"
      }
    ]
  }
}