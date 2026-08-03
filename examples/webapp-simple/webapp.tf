module "hello_world" {
  source = "../../webapp"

  app_config = {
    name            = "hello"
    service_plan_id = module.app_service_plan.id

    # The ILB environment already keeps this app off the internet. Leaving public access enabled
    # avoids stacking a second, private-endpoint style restriction on top of that isolation.
    public_network_access_enabled = true

    # Required inside an App Service Environment, which rejects this being disabled. Also what
    # lets the app pull from the ACR over its private endpoint.
    vnet_image_pull_enabled = true
  }

  env                 = var.env
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  site_config = {
    health_check_path = "/"

    # docker_registry_url is not set: the module derives it from acr_config below.
    application_stack = {
      docker_image_name = var.hello_world_image
    }
  }

  # Pulls the image with the module-managed identity and creates the AcrPull assignment for it.
  acr_config = {
    registry_fqdn = module.acr.login_server
    acr_id        = module.acr.id
  }

  app_settings = {
    # Custom containers do not advertise their port, so App Service has to be told.
    WEBSITES_PORT = var.app_port
  }

  tags = var.tags
}
