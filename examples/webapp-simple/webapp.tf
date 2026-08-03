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

  # Grants the app identity Key Vault Secrets User, which is what resolves the references below.
  kv_config = {
    kv_id = module.keyvault.id
  }

  # Read at runtime by the platform, never written into the app's configuration. versionless_id
  # rather than id, so a rotated secret is picked up within 24 hours instead of pinning a version.
  key_vault_secrets = {
    "DEMO_SECRET" = azurerm_key_vault_secret.demo.versionless_id
  }

  # App settings are how App Service passes environment variables to the container. The app reads
  # every key below as a plain environment variable, whether the value is literal, wired from
  # another resource, or resolved from Key Vault by the key_vault_secrets block above.
  app_settings = {
    # Custom containers do not advertise their port, so App Service has to be told.
    WEBSITES_PORT = var.app_port

    # Literal values.
    APP_ENVIRONMENT = var.env
    LOG_LEVEL       = "info"

    # Wired from other resources rather than hardcoded, so they cannot drift.
    ACR_LOGIN_SERVER = module.acr.login_server
    KEY_VAULT_URI    = module.keyvault.vault_uri

    # Which identity DefaultAzureCredential should use. The app has a user assigned identity, and
    # without this a client library would try the system assigned one and fail. Referencing the
    # module's own output here is not a cycle: the identity does not depend on app_settings.
    AZURE_CLIENT_ID = module.hello_world.identity_client_id
  }

  tags = var.tags
}
